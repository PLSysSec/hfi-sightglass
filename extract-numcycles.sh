#!/bin/bash
# (sh doesn't work because of the string manip this uses)
# usage: ./extract-numcycles.sh <directory containing gem5-output subdirs>

STARTDIR=$(realpath $1)
if [ ! -d $STARTDIR ]; then
	echo "$STARTDIR doesn't exist."
	exit 1
fi

CYCLESDIR=$STARTDIR/../sightglass_simulated_aggregate
mkdir -p $CYCLESDIR

# since we are pulling stats from multiple runs, log the runs used
echo $STARTDIR >> $CYCLESDIR/runs.txt

# get the config from the folder name
if [ $(basename $STARTDIR | grep -o "_guardpage_asmmove_") ]; then
	CONFIG="guardpage_asmmove"
elif [ $(basename $STARTDIR | grep -o "_hfiemulate2_") ]; then
	CONFIG="hfiemulate2"
elif [ $(basename $STARTDIR | grep -o "_hfi_") ]; then
	CONFIG="hfi"	
fi

for dir in $STARTDIR/*; do
    if [ -d $dir ]; then
	if [[ $(cat "$dir"/stats.txt) ]]; then
            echo $dir
	    BASEDIR=$(basename $dir)
            grep "numCycles" $dir/stats.txt | grep -P -o "\s+\d+\s+" | grep -P -o "\d+" > $CYCLESDIR/${BASEDIR::-5}_${CONFIG}
        fi
    fi
done
