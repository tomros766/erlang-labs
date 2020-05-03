%%%-------------------------------------------------------------------
%%% @author tomasz
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 08. kwi 2020 12:25
%%%-------------------------------------------------------------------
-module(pollution_test).
-author("tomasz").

-include_lib("eunit/include/eunit.hrl").

create_test() ->
  ?assertEqual(#{}, pollution:createMonitor()).

add_station_test() ->
  ?assertEqual([{station, "stacja", {0, 0}}], maps:keys(pollution:addStation("stacja", {0, 0}, #{}))),
  ?assertEqual(pollution:addStation("stacja", {0,0}, #{}), #{{station, "stacja", {0,0}} => #{}}).

add_value_test() ->
  ?assertEqual(pollution:addValue("stacja", {{0,0,0}, {0,0,0}}, "Type", 0, pollution:addStation("stacja", {0, 0}, #{})), #{{station, "stacja", {0, 0}} => #{{measurement, {{0,0,0}, {0,0,0}}, "Type"} => 0}}),
  ?assertEqual(pollution:addValue("stacja", calendar:local_time(), "type", 0, #{}), #{}).


remove_value_test() ->
  P = pollution:createMonitor(),
  P1 = pollution:addStation("stacja", {0,0}, P),
  P2 = pollution:addValue("stacja", {{0,0,0}, {0,0,0}}, "Type", 0, P1),
  P3 = pollution:removeValue("stacja", {{0,0,0}, {0,0,0}}, "Type", P2),
  ?assertMatch(P3, P1).

get_one_value_test() ->
  P = pollution:createMonitor(),
  P1 = pollution:addStation("stacja", {0,0}, P),
  P2 = pollution:addValue("stacja", {{0,0,0}, {0,0,0}}, "Type", 0, P1),
  ?assertEqual(pollution:getOneValue({0,0}, {{0,0,0}, {0,0,0}}, "Type", P2), 0).

get_station_mean_test() ->
  P = pollution:createMonitor(),
  P1 = pollution:addStation("stacja", {0,0}, P),
  P2 = pollution:addValue("stacja", {{0,0,0},{0,0,0}}, "type", 0, P1),
  P3 = pollution:addValue("stacja", {{0,0,0}, {0,0,0}}, "type2", 0, P2),
  P4 = pollution:addValue("stacja", {{0,0,1}, {0,0,0}}, "type", 50, P3),
  ?assertEqual(pollution:getStationMean("stacja", "type", P4), 25.0).

get_daily_mean_test() ->
  P = pollution:createMonitor(),
  P1 = pollution:addStation("stacja", {0,0}, P),
  P2 = pollution:addValue("stacja", {{0,0,0},{0,0,0}}, "type", 0, P1),
  P3 = pollution:addValue("stacja", {{0,0,0}, {0,0,0}}, "type2", 0, P2),
  P4 = pollution:addValue("stacja", {{0,0,1}, {0,0,0}}, "type", 50, P3),
  P5 = pollution:addStation("stacja2", {10, 10}, P4),
  P6 = pollution:addValue("stacja2", {{0,0,1}, {0,0,0}}, "type", 40, P5),
  ?assertEqual(pollution:getDailyMean({0,0,1}, "type", P6), 45.0).

get_max_pollution_test() ->
  P = pollution:createMonitor(),
  P1 = pollution:addStation("stacja", {0,0}, P),
  P2 = pollution:addValue("stacja", {{0,0,0},{0,0,0}}, "type", 0, P1),
  P3 = pollution:addValue("stacja", {{0,0,0}, {0,0,0}}, "type2", 0, P2),
  P4 = pollution:addValue("stacja", {{0,0,1}, {0,0,0}}, "type", 50, P3),
  P5 = pollution:addStation("stacja2", {10, 10}, P4),
  P6 = pollution:addValue("stacja2", {{0,0,1}, {0,0,0}}, "type", 40, P5),
  ?assertMatch({_, 50}, pollution:getMaxPollution("type", P6)).

get_mean_from_area_test() ->
  P = pollution:createMonitor(),
  P1 = pollution:addStation("stacja", {0,0}, P),
  P2 = pollution:addValue("stacja", {{0,0,0},{0,0,0}}, "type", 0, P1),
  P3 = pollution:addValue("stacja", {{0,0,0}, {0,0,0}}, "type2", 0, P2),
  P4 = pollution:addValue("stacja", {{0,0,1}, {0,0,0}}, "type", 50, P3),
  P5 = pollution:addStation("stacja2", {10, 10}, P4),
  P6 = pollution:addValue("stacja2", {{0,0,1}, {0,0,0}}, "type", 40, P5),
  P7 = pollution:addStation("stacja3", {1 ,1}, P6),
  P8 = pollution:addValue("stacja3", calendar:local_time(), "type", 10, P7),
  ?assertEqual(pollution:getMeanFromArea("type", {{0,0}, {2,2}}, P8), 20.0).


