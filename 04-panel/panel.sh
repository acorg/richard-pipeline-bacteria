#!/bin/bash -e

. ../common.sh

# The log file is the top-level sample log file, seeing as this step is a
# 'collect' step that is only run once.
log=$sampleLogFile
filenumber=$1
out=summary-bacteria-$filenumber

logStepStart $log
logTaskToSlurmOutput panel $log

function skip()
{
    # We're being skipped. Make an empty output file, if one doesn't
    # already exist. There's nothing much else we can do and there's no
    # later steps to worry about.
    [ -f $out ] || touch $out
}

function panel()
{
    echo "  noninteractive-alignment-panel.py started at $(date)" >> $log

    dbFastaFile=$root/share/ncbi/diamond-dbs/20180609-bacteria.nonredundant_protein.dmnd

    if [ ! -f $dbFastaFile ]
    then
        echo "  DIAMOND database FASTA file $dbfile does not exist!" >> $log
        logStepStop $log
        exit 1
    fi

    tasks=$(tasksForSample $filenumber)

    allJSON=
    allFASTQ=
    for task in $tasks
    do
        echo "  Task (i.e., sequencing run) $task" >> $log

        JSON=../03-diamond/$task.json.bz2
        test -f $JSON || {
            echo "JSON file $JSON does not exist." >> $log
            exit 1
        }

        FASTQ=../02-map/$task-unmapped.fastq.gz
        test -f $FASTQ || {
            echo "FASTQ file $FASTQ does not exist." >> $log
            exit 1
        }

        allJSON="$allJSON $JSON"
        allFASTQ="$allFASTQ $FASTQ"
    done

    local outputDir=out-$(printf '%02d' $filenumber)

    # Remove the output directory because it could be a pre-existing
    # symlink to (slow) cold storage. We'll write to fast disk and sometime
    # later we can archive it if we want. Make sure to remove the
    # destination of the link, if it's a link. Use -f in the rm because
    # although the output file might be a symlink the destination file may
    # be in cold storage and therefore not visible from the compute node.
    if [ -L $outputDir ]
    then
        rm -fr $(readlink $outputDir)
    fi
    rm -fr $outputDir summary-proteins $out

    noninteractive-alignment-panel.py \
      --json $allJSON \
      --fastq $allFASTQ \
      --matcher diamond \
      --outputDir $outputDir \
      --withScoreBetterThan 60 \
      --maxTitles 100 \
      --minMatchingReads 10 \
      --scoreCutoff 50 \
      --minCoverage 0.1 \
      --negativeTitleRegex phage > summary-proteins-$filenumber
    echo "  noninteractive-alignment-panel.py stopped at $(date)" >> $log

    echo "  proteins-to-pathogens.py started at $(date)" >> $log
    echo summary-proteins-$filenumber | proteins-to-pathogens.py > $out
    echo "  proteins-to-pathogens.py stopped at $(date)" >> $log
}


if [ $SP_SIMULATE = "1" ]
then
    echo "  This is a simulation." >> $log
else
    echo "  This is not a simulation." >> $log
    if [ $SP_SKIP = "1" ]
    then
        echo "  Panel is being skipped on this run." >> $log
        skip
    elif [ -f $out ]
    then
        if [ $SP_FORCE = "1" ]
        then
            echo "  Pre-existing output file $out exists, but --force was used. Overwriting." >> $log
            panel
        else
            echo "  Will not overwrite pre-existing output file $out. Use --force to make me." >> $log
        fi
    else
        echo "  Pre-existing output file $out does not exist. Making panel." >> $log
        panel
    fi
fi

logStepStop $log
