%%%-------------------------------------------------------------------
%%% @author tomasz
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 01. kwi 2020 16:28
%%%-------------------------------------------------------------------
-module('ParclLocker').
-author("tomasz").

%% API
-export([test/0, findMyParcelLocker/2, testSeq/3, testConcurr/2, testConcurrAF/2, findMyParcelLockerProc/3, testSeqCon/4]).

findMyParcelLockerProc(PersonLocation, LockerLocations, Parent) ->
  {Xp, Yp} = PersonLocation,
  Dist = lists:min([abs(Xp - Xl) + abs(Yp - Yl) ||  {Xl, Yl} <- LockerLocations]),
  Locker = findLockerByDist(PersonLocation, LockerLocations, Dist),
  Parent ! {PersonLocation, Locker}.

findMyParcelLocker(PersonLocation, LockerLocations) ->
  {Xp, Yp} = PersonLocation,
  Dist = lists:min([abs(Xp - Xl) + abs(Yp - Yl) ||  {Xl, Yl} <- LockerLocations]),
  Locker = findLockerByDist(PersonLocation, LockerLocations, Dist),
  {PersonLocation, Locker}.

findLockerByDist(PersonLocation, LockerLockations, Dist) ->
  {Xp, Yp} = PersonLocation,
  [H | T] = LockerLockations,
  {Xl, Yl} = H,
  if
    abs(Xp - Xl) + abs(Yp - Yl) =:= Dist -> H;
    true -> findLockerByDist(PersonLocation, T, Dist)
  end.

testSeq([], _, Pairs) -> Pairs;
testSeq([H | T], Lockers, Pairs) ->
  Pair = findMyParcelLocker(H, Lockers),
  testSeq(T, Lockers, [Pair | Pairs]).

collect(Pairs, N) ->
  if
    N > 0 ->
      receive
        PairPrt ->
          if
            is_list(PairPrt) ->
              collect(PairPrt ++ Pairs, N - 1);
            true -> collect([PairPrt | Pairs], N - 1)
          end
      end;
    true ->
      Pairs
  end.


testConcurrAF([], Lockers) ->
  collect([], 1000);
testConcurrAF([H | T], Lockers) ->
  spawn(?MODULE, findMyParcelLockerProc, [H, Lockers, self()]),
  testConcurrAF(T, Lockers).

testSeqCon([], _, Pairs, Parent) -> Parent ! Pairs;
testSeqCon([H | T], Lockers, Pairs, Parent) ->
  Pair = findMyParcelLocker(H, Lockers),
  testSeqCon(T, Lockers, [Pair | Pairs], Parent).

testConcurr(People, Lockers) ->
  spawn(?MODULE, testSeqCon, [lists:sublist(People, 1, 250), Lockers, [], self()]),
  spawn(?MODULE, testSeqCon, [lists:sublist(People, 251, 250), Lockers, [], self()]),
  spawn(?MODULE, testSeqCon, [lists:sublist(People, 501, 250), Lockers, [], self()]),
  spawn(?MODULE, testSeqCon, [lists:sublist(People, 751, 250), Lockers, [], self()]),
  collect([], 4).


test() ->
  People = [{rand:uniform(10000), rand:uniform(10000)} || X <- lists:seq(1,1000)],
  Lockers = [{rand:uniform(10000), rand:uniform(10000)} || X <- lists:seq(1,10000)],
  {T1, _} = timer:tc(?MODULE, testSeq, [People, Lockers, []]),
  io:format("Czas wykonania sekwencyjnego: ~b ~n", [T1]),
  {T2, _} = timer:tc(?MODULE, testConcurrAF, [People, Lockers]),
  io:format("Czas wykonania bardzo rownoleglego: ~b ~n", [T2]),
  {T3, _} = timer:tc(?MODULE, testConcurr, [People, Lockers]),
  io:format("Czas wykonania troche rownoleglego: ~b ~n", [T3]).




