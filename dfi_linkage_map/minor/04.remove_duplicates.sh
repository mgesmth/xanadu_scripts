#!/bin/bash

#SBATCH -J 04.Duplicates
#SBATCH -o 98_log_files/%x_%A_%a.out
#SBATCH -e 98_log_files/%x_%A_%a.err
#SBATCH -c 18
#SBATCH --mem=68G

set -e
module load picard/3.1.1 singularity/3.9.2

# Global variables
MARKDUPS="MarkDuplicates"
ALIGNEDFOLDER="06_bam_files"
METRICSFOLDER="99_metrics"
LOG_FOLDER="98_log_files"

export JAVA_TOOL_OPTIONS="-Xms2g -Xmx${SLURM_MEM_PER_NODE}M "
export _JAVA_OPTIONS="-Xms2g -Xmx${SLURM_MEM_PER_NODE}M "

# Fetch filename from the array
array=($(cut -f1 02_info_files/datatable.txt))
name=${array[$SLURM_ARRAY_TASK_ID]}
file=${name}.sorted.bam

    echo "DEduplicatING sample $file"

    java -jar $PICARD $MARKDUPS \
        INPUT=$ALIGNEDFOLDER/$file \
        OUTPUT=$ALIGNEDFOLDER/${name}.dedup.bam \
        METRICS_FILE=$METRICSFOLDER/${name}_DUP_metrics.txt \
        VALIDATION_STRINGENCY=SILENT \
        REMOVE_DUPLICATES=true

echo "DONE! Go check your files."
