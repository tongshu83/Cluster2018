#!/bin/sh
set -eu

# FAKE FOB

# DO NOT NEED THIS FOR CODAR

PARAMS=$1
RUN_ID=$2

cd $TURBINE_OUTPUT

echo PARAMS: $PARAMS
echo RUN_ID: $RUN_ID

mkdir -p run/$RUN_ID

A=( $PARAMS )
RESULT=$(( ${A[0]} + ${A[1]} ))

echo $RESULT > run/$RUN_ID/result.txt
