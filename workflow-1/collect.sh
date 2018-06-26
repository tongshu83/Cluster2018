#!/bin/bash

if [ ${#*} != 1 ]
then
    echo "$0 filename"
    exit 1
fi

for ht_procs_x in {1..4}
do
    for ht_procs_y in {1..4}
    do
        for sw_procs in {1..16}
        do
            file="/home/tshu/project/Cluster2018/workflow-1/experiments/X01/run/$(echo $ht_procs_x)_$(echo $ht_procs_y)_$sw_procs/out.txt"
            value=$(cat $file)
            echo -e "$ht_procs_x\t$ht_procs_y\t$sw_procs\t$value\t" >> $1.dat
        done
    done
done

exit 0

