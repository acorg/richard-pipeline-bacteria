#!/bin/bash -e

. ../common.sh

task=$1
log=$logDir/sbatch.log
# The following must have the identical value as is set in map.sh
out=$task.json.bz2

echo "$(basename $(pwd)) sbatch.sh running at $(date)" >> $log
echo "  Task is $task" >> $log
echo "  Dependencies are $SP_DEPENDENCY_ARG" >> $log

if [ "$SP_FORCE" = "0" -a -f $out ]
then
    # The output file already exists and we're not using --force, so
    # there's no need to do anything. Just pass along our task name to the
    # next pipeline step.
    echo "  Ouput file $out already exists and SP_FORCE is 0. Nothing to do." >> $log
    echo "TASK: $task"
else
    if [ "$SP_SIMULATE" = "1" -o "$SP_SKIP" = "1" ]
    then
        exclusive=
        echo "  Simulating or skipping. Not requesting exclusive node." >> $log
    else
        # Request an exclusive machine because diamond.sh will tell DIAMOND to
        # use all available cores.
        exclusive=--exclusive
        echo "  Not simulating or skipping. Requesting exclusive node." >> $log
    fi

    jobid=$(sbatch -n 1 $exclusive $SP_DEPENDENCY_ARG $SP_NICE_ARG submit.sh $task | cut -f4 -d' ')
    echo "TASK: $task $jobid"
    echo "  Job id is $jobid" >> $log
fi

echo >> $log
