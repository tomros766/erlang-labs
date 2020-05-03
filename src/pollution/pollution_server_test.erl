%%%-------------------------------------------------------------------
%%% @author tomasz
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 08. kwi 2020 12:23
%%%-------------------------------------------------------------------
-module(pollution_server_test).
-author("tomasz").

-include_lib("eunit/include/eunit.hrl").

start_test() ->
  pollution_server:start(),
  ?assert(lists:member(monitor, registered())).

add_station_test() ->
  ?assertEqual(ok, pollution_server:addStation("stacja", {0, 0})).

get_one_value_test() ->
  pollution_server:addValue("stacja", {{0,0,0},{0,0,0}}, "type", 0),
  ?assertEqual(0, pollution_server:getOneValue("stacja", {{0,0,0}, {0,0,0}}, "type")).

stop_test() ->
  pollution_server:stop(),
  timer:sleep(100),
  ?assert(not lists:member(monitor, registered())).


