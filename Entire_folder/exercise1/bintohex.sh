#!/usr/bin/env bash

FILE="$1"
MEM_WORDS="$2"

NUMBER_TEST="^[0-9]+$"
if ! [[ ${MEM_WORDS} =~ ${NUMBER_TEST} ]]
then
    MEM_WORDS=0
fi

hexdump "${FILE}" -v '-e"%08x\n"'

LINES="$(expr $(du -b "${FILE}" | cut -f -1) / 4)"

for (( c="${LINES}"; c<"${MEM_WORDS}"; c++ ))
do
    echo 00000000
done