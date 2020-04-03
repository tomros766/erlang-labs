%%%-------------------------------------------------------------------
%%% @author tomasz
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 01. kwi 2020 14:12
%%%-------------------------------------------------------------------
-module(warmup).
-author("tomasz").

%% API
-export([fun1/0, loop/1]).

fun1 () ->
  receive
    _ -> io:format("Otrzymalem wiadomosc! ~n")
  end.

loop(N) ->
  receive
    inc -> loop(N + 1);
    print -> io:format("~B~n",[N]), loop(N);
    stop -> ok
  end.
