%%%-------------------------------------------------------------------
%%% @author lhfcws
%%% @copyright (C) 2014, SYSU
%%% @doc
%%%
%%% @end
%%% Created : 21. 十一月 2014 12:43
%%%-------------------------------------------------------------------
-module(chat_server).
-author("lhfcws").

%% API
-export([start/0]).

-define(SERVER, ?MODULE).
-define(PORT, 1055).

%% -record(server, {
%%   users,    %   [ClientPid]
%%   boards,   %   [Board]
%%   history,  %   Chat history
%%   maxconn,  %   Max connection amount of Clients
%%   n_conn,      %   Current connection amount of Clients
%%   lsocket
%% }).

init() ->
  {ok, Lsocket} = gen_tcp:listen(?PORT, [binary, {packet, 0}, {active, false}]),
  put(users, []),
  put(maxconn, 0),
  put(history, []),
  put(boards, []),
  put(lsocket, Lsocket)
.

add_user(_, From) ->
  put(maxconn, get(maxconn) + 1),
  put(users, [From | get(users)])
.

server_loop() ->
  Pid = self(),
  LSocket = get(lsocket),
  receive
    {From, new_user_req, Username} ->
      common_util:print("new_user_req"),
      HasUser = lists:keyfind(Username, 1, get(users)),
      MaxLimit = get(maxconn) == get(conn),
      case {HasUser, MaxLimit} of
        {false, false} ->
          common_util:print(["new_user  ", Username]),
          add_user(Username, From),
          From ! ok,
          spawn(fun() -> client_listener(Pid, LSocket) end);
        {_, _} -> From ! error
      end;

    {From, new_board} ->
      common_util:print("new_board"),
      put(boards, [From | get(boards)]),
      From ! {ok, get(history)},
      spawn(fun() -> client_listener(Pid, LSocket) end);

    {From, new_msg, Msg} ->
      common_util:print("new_msg"),
      put(history, [Msg | get(history)]),
      lists:map(fun(Board) ->
        Board ! {new_msg, Msg}
      end, get(boards));

    Other ->
      io:write(Other)
  end,
  server_loop()
.

start() ->
  init(),
  LSocket = get(lsocket),
  io:format("Server started. Server state: ~w~n", [LSocket]),
  Pid = self(),
  spawn(fun() -> client_listener(Pid, LSocket) end),
  server_loop()
.

listen(From, Socket) ->
  Msg = recv(Socket),
  Pid = self(),
  From ! {Pid, new_msg, Msg},
  listen(From, Socket)
.

board(Socket) ->
  receive
    {new_msg, Line} -> send(Socket, Line)
  end,
  board(Socket)
.

client_listener(From, LSocket) ->
  Pid = self(),
  try
    case gen_tcp:accept(LSocket) of
      {ok, Socket} ->

        io:format("New connection established.~n", []),
        Packet = recv(Socket),

        case Packet of
          [new_user, "||", Username] ->
            io:write(From),
            From ! {Pid, new_user_req, Username},
            receive
              ok ->
                send(Socket, "ok"),
                listen(From, Socket);
              error ->
                send(Socket, "Auth failed.")
            end;

          [new_board, "||"] ->
            From ! {Pid, new_board},
            receive
              {ok, History} ->
                lists:foreach(fun(Line) ->
                  send(Socket, Line)
                end, History);
              error ->
                common_util:print("New board failed.~n")
            end,
            board(Socket)
        end;

      Other ->
        io:format("Accept Error: ~w~n", [Other])
    end
  catch
    error:Reason ->
      io:format("Error: ~w~n", [Reason]),
      client_listener(From, LSocket)
  end
.

send(Socket, Msg) ->
  gen_tcp:send(Socket, term_to_binary(Msg))
.

recv(Socket) ->
  common_util:socket_recv(Socket, [])
.

