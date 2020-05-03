%%%-------------------------------------------------------------------
%%% @author tomasz
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 08. kwi 2020 11:11
%%%-------------------------------------------------------------------
-module(pollution_server).
-author("tomasz").
-import(pollution, [addStation/3, addValue/5, removeValue/4, getOneValue/4, getStationMean/3, getDailyMean/3, getMeanFromArea/3, getMaxPollution/2]).

%% API
-export([start/0, init/1, stop/0, addStation/2,  addValue/4, removeValue/3, getOneValue/3, getStationMean/2, getDailyMean/2, getMeanFromArea/2, getMaxPollution/1]).


start() ->
  register(monitor, spawn(?MODULE, init, [#{}])).

init(Monitor) ->
  loop(Monitor).

stop() ->
  monitor ! stop.

loop(Monitor) ->
  receive
    {request, Pid, addStation, Name, Coords} ->
      Pid ! ok,
      NewMonitor = addStation(Name, Coords, Monitor),
      loop(NewMonitor);
    {request, Pid, addValue, Key, Date, Type, Value} ->
      Pid ! ok,
      NewMonitor = addValue(Key, Date, Type, Value, Monitor),
      loop(NewMonitor);
    {request, Pid, removeValue, Key, Date, Type} ->
      Pid ! ok,
      NewMonitor = removeValue(Key, Date, Type, Monitor),
      loop(NewMonitor);
    {request, Pid, getOneValue, Key, Date, Type} ->
      Pid ! getOneValue(Key, Date, Type, Monitor),
      loop(Monitor);
    {request, Pid, getStationMean, Key, Type} ->
      Pid ! getStationMean(Key, Type, Monitor),
      loop(Monitor);
    {request, Pid, getDailyMean, Day, Type} ->
      Pid ! getDailyMean(Day, Type, Monitor),
      loop(Monitor);
    {request, Pid, getMeanFromArea, Type, Border} ->
      Pid ! getMeanFromArea(Type, Border, Monitor),
      loop(Monitor);
    {request, Pid, getMaxPollution, Type} ->
      Pid ! getMaxPollution(Type, Monitor),
      loop(Monitor);
    stop -> ok
  end.

addStation(Name, Coords) ->
  monitor ! {request, self(), addStation, Name, Coords},
  receive
    ok -> ok;
    {error, Msg} -> 
        io:format("~s~n", [Msg]),
        error
  end.

addValue(Key, Date, Type, Value) ->
  monitor ! {request, self(), addValue, Key, Date, Type, Value},
  receive
    ok -> ok;
    {error, Msg} -> 
        io:format("~s~n", [Msg]),
        error
  end.

removeValue(Key, Date, Type) ->
  monitor ! {request, self(), removeValue, Key, Date, Type},
  receive
    ok -> ok;
    {error, Msg} -> 
        io:format("~s~n", [Msg]),
        error
  end.

getOneValue(Key, Date, Type) ->
  monitor ! {request, self(), getOneValue, Key, Date, Type},
  receive
    Value -> Value
  end.

getStationMean(Key, Type) ->
  monitor ! {request, self(), getStationMean, Key, Type},
  receive
    Value -> Value
  end.

getDailyMean(Day, Type) ->
  monitor ! {request, self(), getDailyMean, Day, Type},
  receive
    Value -> Value
  end.

getMeanFromArea(Type, Border) ->
  monitor ! {request, self(), Type, Border},
  receive
    Value -> Value
  end.

getMaxPollution(Type) ->
  monitor ! {request, self(), getMaxPollution, Type},
  receive
    Value -> Value
  end.

