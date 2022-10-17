#!/bin/sh

# usage: ./extract-numcycles.sh <directory containing gem5-output subdirs>
STARTDIR=$1
mkdir -p $STARTDIR/cycle_counts

for dir in $STARTDIR/*; do
    if [ -d $dir ]; then
        if [ -f $dir/stats.txt ]; then
            echo $dir
            grep "numCycles" $dir/stats.txt | grep -P -o "\s+\d+\s+" | grep -P -o "\d+" > $STARTDIR/cycle_counts/$(basename $dir)
        fi
    fi
done
