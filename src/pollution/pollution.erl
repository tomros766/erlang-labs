%%%-------------------------------------------------------------------
%%% @author tomasz
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 04. kwi 2020 15:29
%%%-------------------------------------------------------------------
-module(pollution).
-compile(export_all).
-author("tomasz").
-record(station, {name, coords}).
-record(measurement, {date, type}).

%% API


% funkcja na podstawie nazwy lub wspolrzednych zwraca cala krotke (pelny klucz w mapie)
getFullKey([], Key) -> error;
getFullKey([#station{name=Key, coords=Coords} | _], Key) -> #station{name=Key, coords=Coords};
getFullKey([#station{name=Name, coords=Key} | _], Key) -> #station{name=Name, coords=Key};
getFullKey([_ | T], Key) -> getFullKey(T, Key).

% funkcja wylicza srednia wartosc w liscie
getMean([], Sum, Size) -> Sum/Size;
getMean([H | T], Sum, Size) -> getMean(T, Sum + H, Size + 1).


%funkcja zwraca nowa, pusta mape
createMonitor() ->
  #{}.

%funkcja dodaje stacje pomiaru do monitora
addStation(Name, Coords, Monitor) ->
  ValName = getFullKey(maps:keys(Monitor), Name),
  ValCoords = getFullKey(maps:keys(Monitor), Coords),
  case ValName of
    error -> case ValCoords of
               error -> Monitor#{#station{name=Name, coords=Coords} => maps:new()};
               _ -> {error, "Monitor o takiej nazwie istnieje!"}
             end;
    _ -> {error, "Monitor o takiej nazwie istnieje!"}
  end.

%funkcja dodaje wartosc do dane stacji
addValue(Key, Date, Type, Value, Monitor) ->
  Values = maps:find(getFullKey(maps:keys(Monitor), Key), Monitor),
  case Values of
    error -> {error, "Stacja nie istnieje!"};
    {ok, Measurements} -> TestVal = maps:find(#measurement{date=Date, type=Type}, Measurements),
      case TestVal of
        error ->
          Size = maps:size(Measurements),
          if
            Size =:= 0 -> maps:put(getFullKey(maps:keys(Monitor), Key), maps:put(#measurement{date=Date, type=Type}, Value, Measurements), Monitor);
            true -> maps:update(getFullKey(maps:keys(Monitor), Key),maps:put(#measurement{date=Date, type=Type}, Value, Measurements), Monitor)
          end;
        _ -> {error, "Pomiar tego typu o tej godzinie juz istnieje!"}
          
      end
  end.

%funkcja usuwa pomiar z danej stacji
removeValue(Key, Date, Type, Monitor) ->
  Values = maps:find(getFullKey(maps:keys(Monitor), Key), Monitor),
  case Values of
    error -> {error, "Stacja nie istnieje!"};
    {ok, Measurements} ->  maps:update(getFullKey(maps:keys(Monitor), Key), maps:remove(#measurement{date=Date, type=Type}, Measurements), Monitor)
  end.

%funkcja zwraca wartosc konkretengo pomiaru z danej stacji
getOneValue(Key, Date, Type, Monitor) ->
  Values = maps:find(getFullKey(maps:keys(Monitor), Key), Monitor),
  case Values of
    error -> {error, "Stacja nie istnieje!"};
    {ok, Measurements} -> Value = maps:find(#measurement{date=Date, type=Type}, Measurements),
      case Value of
        error -> {error, "Brak pomiaru"};
        {ok, Val} -> Val
      end
  end.

%funkcja zwraca srednia wartosc danego typu zanieczyszczen z danej stacji
getStationMean(Key, Type, Monitor) ->
  FullKey = maps:find(getFullKey(maps:keys(Monitor), Key), Monitor),
  case FullKey of
    error -> {error, "Stacja nie istnieje!"};
    {ok, Measurements} ->
      getMean(filterByType(maps:to_list(Measurements), Type, []), 0, 0)
  end.

%funkcja zwraca srednia wartosc danego typu zanieczyszczen ze wszystkich stacji w ciagu danego dnia
getDailyMean(Day, Type, Monitor) ->
  Measurements = maps:values(Monitor),
  Filtered = filterByDay(Measurements, Day, Type, []),
  getMean(Filtered, 0, 0).

%funkcja zwraca liste wartosci pomiarow, ktore odbyly sie danego dnia
filterByDay([], Day, Type, Vals) -> Vals;
filterByDay([H | T], Day, Type, Vals) ->
  Keys = maps:keys(H),
  Key = isMember(Keys, Day, Type),
  case Key of
    error -> filterByDay(T, Day, Type, Vals);
    _ ->
      {_, Val} = maps:find(Key, H),
      filterByDay(T, Day, Type, [Val | Vals])
  end.

%funkcja sprawcza czy dany pomiar istnieje w zbiorze pomiarow, zwraca klucz jesli istnieje lub error w przeciwnym wypadku
isMember([], Day, Type) -> error;
isMember([H|T], Day ,Type)  ->
  case H of
    #measurement{date={Day, _}, type=Type} -> H;
    _ -> isMember(T, Day, Type)
  end.

%funkcja zwraca liste wartosci pomiarow danego typu
filterByType([], _, Vals) -> Vals;
filterByType([H | T], Type, Vals) ->
  case H of
    {#measurement{type=Type}, Val} -> filterByType(T, Type, [Val | Vals]);
    _ -> filterByType(T, Type, Vals)
  end.

%funkcja zwraca liste wartosci pomiarow z danego obszaru
filterByArea(_, [], Vals) -> Vals;
filterByArea({{Xl, Yl}, {Xr, Yr}}, [{#station{coords={X, Y}}, Val} | T] , Vals) when X >= Xl, X =< Xr, Y >= Yl, Y =< Yr ->
  filterByArea({{Xl, Yl}, {Xr, Yr}}, T, [Val | Vals]);
filterByArea(Border, [_ | T], Vals) -> filterByArea(Border, T, Vals).

% funkcja zwraca informacje o najwyzszej wartosci pomiarow danego typu wraz z informacja z ktorej stacji pochodzi pomiar
getMaxPollution(Type, Monitor) ->
  Values = getMaxValuesWithStation(Monitor, maps:keys(Monitor), Type, []),
  getMaxWithStation(Values, station, 0).


%funkcja zwraca krotke {stacja, wartosc} dla najwiekszej wartosci pomiaru
getMaxWithStation([], MaxStation, MaxVal) -> {MaxStation, MaxVal};
getMaxWithStation([{Station, Val} | T], _, MaxVal) when Val > MaxVal -> getMaxWithStation(T, Station, Val);
getMaxWithStation([_ | T], MaxStation, MaxVal) -> getMaxWithStation(T, MaxStation, MaxVal).


%funkcja zwraca liste najwiekszych wartosci danego pomiaru wraz z informacja z ktorej stacji pochodzi pomiar
getMaxValuesWithStation(Monitor, [], Type, Values) -> Values;
getMaxValuesWithStation(Monitor, [Key | Keys], Type, Values) ->
  Vals = filterByType(maps:to_list(maps:get(Key, Monitor)), Type, []),
  getMaxValuesWithStation(Monitor, Keys, Type, [{Key, lists:max(Vals)} | Values]).


%funkcja zwraca liste wartosci pomiaru danego typu wraz z inforamcja o stacji
getValuesWithStation(Monitor, [], Type, Values) -> Values;
getValuesWithStation(Monitor ,[Key | Keys], Type, Values) ->
  Vals = filterByType(maps:to_list(maps:get(Key, Monitor)), Type, []),
  getValuesWithStation(Monitor, Keys, Type, [{Key, Val} || Val <- Vals] ++ Values).


%funkcja zwraca srednia wartosc pomiaru danego typu w danym obszarze na wszystkich stacjach, funkcja przyjmuje wspolrzede {lewy_dolny, prawy_gorny}
getMeanFromArea(Type, Border, Monitor) ->
  Values = getValuesWithStation(Monitor, maps:keys(Monitor), Type, []),
  Filtered = filterByArea(Border, Values, []),
  getMean(Filtered, 0, 0).







