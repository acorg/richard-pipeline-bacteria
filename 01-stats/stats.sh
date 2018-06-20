#!/bin/bash -e

. ../common.sh

task=$1
log=$logDir/$task.log
fastq=$dataDir/$task.fastq
countOut=$task.count
MD5Out=$task.md5

logStepStart $log
logTaskToSlurmOutput $task $log
checkFastq $fastq $log

function stats()
{
    # Remove all output files before doing anything, in case we fail for
    # some reason.
    rm -f $countOut $MD5Out

    # Count reads.
    echo "$fastq $(cat $fastq | egrep '^\+$' | wc -l | awk '{print $1}')" > $countOut

    md5sum $fastq > $MD5Out
}

if [ $SP_SIMULATE = "1" ]
then
    echo "  This is a simulation." >> $log
else
    echo "  This is not a simulation." >> $log
    if [ $SP_SKIP = "1" ]
    then
        echo "  Stats is being skipped on this run." >> $log
    elif [ -f $countOut -a -f $MD5Out ]
    then
        if [ $SP_FORCE = "1" ]
        then
            echo "  Pre-existing output files $countOut and $MD5Out exist, but --force was used. Overwriting." >> $log
            stats
        else
            echo "  Will not overwrite pre-existing output files $countOut and $MD5Out. Use --force to make me." >> $log
        fi
    else
        echo "  Pre-existing output files $countOut and $MD5Out do not both not exist. Collecting stats." >> $log
        stats
    fi
fi

logStepStop $log
