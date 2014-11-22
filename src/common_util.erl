%%%-------------------------------------------------------------------
%%% @author lhfcws
%%% @copyright (C) 2014, SYSU
%%% @doc
%%%
%%% @end
%%% Created : 20. 十一月 2014 15:13
%%%-------------------------------------------------------------------
-module(common_util).
-author("lhfcws").

%% API
-export([for_/3, if_/2, ifelse_/3, timestamp/0, while_/2, ok_call/3, socket_recv/2, print/1]).

for_(I, Max, F) ->
  case I == Max of
    false -> [F(I) | for_(I + 1, Max, F)];
    true -> [F(Max)]
  end.

if_(Cond, F) ->
  case Cond of
    true -> F()
  end.

ifelse_(Cond, F1, F2) ->
  case Cond of
    true -> F1();
    false -> F2()
  end.

while_(true, F) ->
  F(),
  while_(true, F);
while_(false, _) ->
  false.

timestamp() ->
  {MegaSec, Sec, _} = os:timestamp(),
  MegaSec * 100000 + Sec.

ok_call(ok, F, Args) ->
  F(Args);
ok_call(_, _, _) ->
  error.

socket_recv(Socket, List) ->
  case gen_tcp:recv(Socket, 0) of
    {ok, Byte} ->
      Bin = list_to_binary([Byte | List]),
      Str = binary_to_term(Bin)
%%       socket_recv(Socket, [Byte | List]);
%%     {error, closed} ->
%%       Bin = list_to_binary(List),
%%       Str = binary_to_term(Bin),
%%       io:format("Debug recv: ~w~n", [Str]),
%%       {ok, Str}
  end
.

print(String) ->
  io:format([String, $\n], [])
.
