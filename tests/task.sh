#!/bin/sh

DELAY=$1
MESSAGE=$2

printf "TASK.SH START %03i %s\n" $DELAY $MESSAGE 
sleep $DELAY
printf "TASK.SH STOP  %03i %s\n" $DELAY $MESSAGE
