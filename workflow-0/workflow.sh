#!/bin/sh
set -eu

# WORKFLOW.SH

if [ ${#} = 0 ]
then
  echo "usage: workflow.sh <WF> <N>?"
  echo "  WF is the workflow number (workflow-WF.swift)"
  echo "  N  is the processor count (default 8)"
  exit
fi

WF=$1
PROCS=${2:-33}

MACHINE=${MACHINE:-}

THIS=$( cd $( dirname $0 ) ; /bin/pwd )
#LAUNCH=$( cd $THIS/../../src ; /bin/pwd )
#LAUNCH_SWIFT=$LAUNCH/launch.swift

cd $THIS

WORKFLOW_SWIFT=workflow-$WF.swift
WORKFLOW_TIC=${WORKFLOW_SWIFT%.swift}.tic

set -x
stc $WORKFLOW_SWIFT

# export VALGRIND="valgrind --suppressions=$HOME/swift-t/turbine/code/turbine.supp"
turbine -l -n $PROCS $MACHINE $WORKFLOW_TIC
