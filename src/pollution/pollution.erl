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


getFullKey([], Key) -> error;
getFullKey([#station{name=Key, coords=Coords} | _], Key) -> #station{name=Key, coords=Coords};
getFullKey([#station{name=Name, coords=Key} | _], Key) -> #station{name=Name, coords=Key};
getFullKey([_ | T], Key) -> getFullKey(T, Key).


getMean([], Sum, Size) -> Sum/Size;
getMean([H | T], Sum, Size) -> getMean(T, Sum + H, Size + 1).

createMonitor() ->
  #{}.

addStation(Name, Coords, Monitor) ->
  ValName = getFullKey(maps:keys(Monitor), Name),
  ValCoords = getFullKey(maps:keys(Monitor), Coords),
  case ValName of
    error -> case ValCoords of
               error -> Monitor#{#station{name=Name, coords=Coords} => maps:new()};
               _ -> io:format("Monitor o takich wspolrzednych juz istnieje! ~n"),
                 Monitor
             end;
    _ -> io:format("Monitor o takiej nazwie już istnieje! ~n "),
        Monitor
  end.

addValue(Key, Date, Type, Value, Monitor) ->
  Values = maps:find(getFullKey(maps:keys(Monitor), Key), Monitor),
  case Values of
    error -> io:format("Stacja nie istnieje! ~n"),
              Monitor;
    {ok, Measurements} -> TestVal = maps:find(#measurement{date=Date, type=Type}, Measurements),
      case TestVal of
        error ->
          Size = maps:size(Measurements),
          if
            Size =:= 0 -> maps:put(getFullKey(maps:keys(Monitor), Key), maps:put(#measurement{date=Date, type=Type}, Value, Measurements), Monitor);
            true -> maps:update(getFullKey(maps:keys(Monitor), Key),maps:put(#measurement{date=Date, type=Type}, Value, Measurements), Monitor)
          end;
        _ -> io:format("Pomiar tego typu o tej godzinie juz istnieje! ~n"),
          Monitor
      end
  end.


removeValue(Monitor, Key, Date, Type) ->
  FullKey = maps:find(getFullKey(maps:keys(Monitor), Key), Monitor),
  case FullKey of
    error -> io:format("Nie ma takiej stacji! ~n"),
      Monitor;
    {ok, Measurements} -> maps:remove(#measurement{date=Date, type=Type}, Measurements),
      Monitor
  end.


getOneValue(Monitor, Key, Date, Type) ->
  FullKey = maps:find(getFullKey(maps:keys(Monitor), Key), Monitor),
  case FullKey of
    error -> io:format("Nie ma takiej stacji! ~n");
    {ok, Measurements} -> Value = maps:find(#measurement{date=Date, type=Type}, Measurements),
      case Value of
        error -> io:format("brak pomiaru! ~n");
        {ok, Val} -> Val
      end
  end.

getStationMean(Monitor, Key, Type) ->
  FullKey = maps:find(getFullKey(maps:keys(Monitor), Key), Monitor),
  case FullKey of
    error -> io:format("Nie ma takiej stacji! ~n");
    {ok, Measurements} ->
      getMean(filterByType(maps:to_list(Measurements), Type, []), 0, 0)
  end.

getDailyMean(Monitor, Day, Type) ->
  Measurements = maps:values(Monitor),
  Filtered = filterByDay(Measurements, Day, Type, []),
  getMean(Filtered, 0, 0).


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

isMember([], Day, Type) -> error;
isMember([H|T], Day ,Type)  ->
  case H of
    #measurement{date={Day, _}, type=Type} -> H;
    _ -> isMember(T, Day, Type)
  end.


filterByType([], _, Vals) -> Vals;
filterByType([H | T], Type, Vals) ->
  case H of
    {#measurement{type=Type}, Val} -> filterByType(T, Type, [Val | Vals]);
    _ -> filterByType(T, Type, Vals)
  end.