#!/bin/bash

if [ ${#*} != 1 ]
then
    echo "$0 filename"
    exit 1
fi

dirs=$(find $HOME/project/Cluster2018/workflow-2/experiments/X01/run/ -mindepth 1 -maxdepth 1 -type d)

for dir in ${dirs[@]}
do
    dir=$(echo $dir | sed -e "s/\n//g" | sed -e "s/ //g")
    file="$dir/out.txt"
    data=$(cat $file)
    echo -e "$data" >> $1.dat
done

exit 0

