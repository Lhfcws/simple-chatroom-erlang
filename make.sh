#!/bin/sh

echo "Mkdir directory structure if not existed: "
mkdir -p include 
mkdir -p ebin

echo "Compiling projects."
erlc -pa include/ -o ebin/ src/*.erl

