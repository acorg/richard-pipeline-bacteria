#!/bin/bash -e

. ../common.sh

task=$1
log=$logDir/sbatch.log

# The following two must have the identical values as are set in stats.sh
countOut=$task.count
MD5Out=$task.md5


echo "$(basename $(pwd)) sbatch.sh running at $(date)" >> $log
echo "  Task is $task" >> $log
echo "  Dependencies are $SP_DEPENDENCY_ARG" >> $log

if [ "$SP_FORCE" = "0" -a -f $countOut -a -f $MD5Out ]
then
    # The output files already exists and we're not using --force, so
    # there's no need to do anything. Just pass along our task name to the
    # next pipeline step.
    echo "  Ouput files $countOut and $MD5Out already exists and SP_FORCE is 0. Nothing to do." >> $log
    echo "TASK: $task"
else
    jobid=$(sbatch -n 1 $SP_NICE_ARG $SP_DEPENDENCY_ARG submit.sh $task | cut -f4 -d' ')
    echo "TASK: $task $jobid"
    echo "  Job id is $jobid" >> $log
fi

echo >> $log
