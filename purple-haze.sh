#!/bin/bash

if [ "${PURPLEHAZE}" == "" ]; then PURPLEHAZE=game.purple-haze; fi
if [ "${PURPLEHAZEDATA}" == "" ]; then PURPLEHAZEDATA=purple-haze.sql; fi
if [ "${SQLITE3}" == "" ]; then SQLITE3=sqlite3; fi

if [ ! -f "${PURPLEHAZE}" ]; then
    cat ${PURPLEHAZEDATA} | ${SQLITE3} ${PURPLEHAZE};
    ${SQLITE3} ${PURPLEHAZE} 'insert into game (id) values (1)';
fi

display()
{
    ${SQLITE3} ${PURPLEHAZE} 'select diff from voutputansi'
}

updateScreenResolution()
{
    COLUMNS=$(tput cols)
    LINES=$(tput lines)
    ${SQLITE3} ${PURPLEHAZE} "update game set columns=$COLUMNS, lines=$LINES"
    clear
    display
}

updateScreenResolution

stty -echo

# while loop
while IFS= read -r -n1 -u0 input
do
    if [ "$input" = "Q" ]; then clear; break; fi;
    if [ "$input" = "R" ]; then updateScreenResolution; continue; fi;
    if [ "$input" = "'" ]; then continue; fi;
    ${SQLITE3} ${PURPLEHAZE} "insert into vkeypress (key) values ('$input')"
    display;
done

echo -en "\e[2J\e[0;37m"
stty echo
