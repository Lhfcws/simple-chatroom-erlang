%%%-------------------------------------------------------------------
%%% @author lhfcws
%%% @copyright (C) 2014, SYSU
%%% @doc
%%%
%%% @end
%%% Created : 20. 十一月 2014 16:40
%%%-------------------------------------------------------------------
-module(chat_client).
-author("lhfcws").

%% API
-export([client/0, board/0]).

-define(PORT, 1055).
-define(HOST, "0.0.0.0").
-define(FILEPATH, "~/tmp/chat_history.txt").
-define(SEP, "||").


send(Msg) ->
  gen_tcp:send(get(sock), term_to_binary(Msg))
.

recv() ->
  common_util:socket_recv(get(sock), [])
.

loopUser() ->
  Username = get(username),
  Prompt = ["[", Username, "] >  "],
  Msg = io:get_line(Prompt),
  send(["[", Username, "] >  ", Msg]),
  loopUser()
.

create_sock() ->
  {Status, Socket} = gen_tcp:connect(?HOST, ?PORT, [binary, {active, false}, {packet, 0}]),
  case Status of
    ok -> put(sock, Socket), io:format("Connection established.~n", []), ok;
    error -> io:format("Connection establish error : ~w~n", [Socket]), error
  end
.

auth(Username) ->
  Str = [new_user, ?SEP, Username],
  case send(Str) of
    ok ->
      case recv() of
        "ok" -> put(username, Username), ok;
        Other -> io:format("Log in connection failed: ~w~n", [Other]), error
      end;

    {error, Reason} -> io:format("Log in connection failed: ~w~n", [Reason]), error
  end
.

%% save_chat(Msg) ->
%%   FD = file:open(?FILEPATH, [append]),
%%   try
%%     io:fwrite(FD, "~w~n", Msg),
%%     ok
%%   catch
%%     _:_ -> error
%%   after
%%     file:close(FD)
%%   end
%% .

%% board() ->
%%   Msg = recv(),
%%   save_chat(Msg),
%%   board()
%% .

client() ->
  create_sock(),
  U = io:get_line("Input your username: "),
  Username = string:strip(U, both, $\n),
  ok = auth(Username),
  io:format("Auth success.~n", []),
  loopUser()
.

board_loop() ->
  Msg = recv(),
  io:format(Msg, []),
  board_loop()
.

board() ->
  ok = create_sock(),
  ok = send([new_board, ?SEP]),
  io:format("History board started.~n", []),
  board_loop()
.

