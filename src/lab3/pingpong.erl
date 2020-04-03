%%%-------------------------------------------------------------------
%%% @author tomasz
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 01. kwi 2020 14:27
%%%-------------------------------------------------------------------
-module(pingpong).
-author("tomasz").

%% API
-export([start/0, play/1, stop/0]).

ping(S)-> receive
           0 -> ping(S);
           N ->
             if
              is_number(N) ->
                io:format("PING ~B, suma otrzymanych liczb: ~B ~n",[N, S+N]),

                timer:sleep(1000),
                pong ! N-1,
                ping(S + N);
              true -> N
             end
         after
           20000 ->
             io:format("PING: minelo 20 sekund bezczynnosci ~n"),
             ok
         end.

pong() -> receive
            0 -> pong();
            N ->
             if
               is_number(N) ->
                  io:format("PONG ~B ~n",[N]),
                  timer:sleep(1000),
                  ping ! N-1,
                  pong();
                 true -> N
             end
          after
            20000 ->
              io:format("PONG: minelo 20 sekund bezczynnosci ~n"),
              ok
          end.

start() ->
  register(ping, spawn(fun() -> ping(0) end)),
  register(pong, spawn(fun() -> pong() end)).

stop() ->
  ping ! ok,
  pong ! ok.

play(N) -> ping ! N.
