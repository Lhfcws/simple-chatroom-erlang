%%%-------------------------------------------------------------------
%%% @author lhfcws
%%% @copyright (C) 2014, SYSU
%%% @doc
%%%
%%% @end
%%% Created : 20. 十一月 2014 19:33
%%%-------------------------------------------------------------------
-module(match_ptest).
-author("lhfcws").

%% API
-export([for_/3, for__/3, for_test/0, for__test/0, gen_list/1]).

-define(SERVER, ?MODULE).

for_(I, Max, F) ->
  case I >= Max of
    false -> [F(I) | for_(I + 1, Max, F)];
    true -> []
  end.

for__(Max, Max, _) ->
  [];
for__(I, Max, F) ->
  [F(I) | for__(I + 1, Max, F)].


%% ===== testApi
gen_list(Range) ->
  case Range of
    _ when Range > 0 -> [Range | gen_list(Range - 1)];
    _ when Range =< 0 -> []
  end.

timestampInMicro() ->
  {_, Sec, Micro} = os:timestamp(),
  Sec * 100000 + Micro.

for_test() ->
  for__(1, 5, fun(_)->
    StartTime = timestampInMicro(),
    for_(1, 1000000, fun(I) -> I + 1 end),
    Diff = timestampInMicro() - StartTime,
    io:format("for_test Cost: ~d", Diff)
  end).

for__test() ->
  for__(1, 5, fun()->
    StartTime = timestampInMicro(),
    for__(1, 1000000, fun(I) -> I + 1 end),
    Diff = timestampInMicro() - StartTime,
    io:format("for__test Cost: ~d", Diff)
  end).
