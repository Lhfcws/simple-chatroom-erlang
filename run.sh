#!/bin/sh

ROLE=$@

cd ebin

if [ "$ROLE" = "client" ]; then
    erl -noshell -s chat_client client -s init stop
elif [ "$ROLE" = "board" ]; then
    erl -noshell -s chat_client board -s init stop
elif [ "$ROLE" = "server" ]; then
    erl -noshell -s chat_server start -s init stop
fi

cd ..