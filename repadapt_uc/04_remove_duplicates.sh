#!/bin/bash
# 1 CPU
# 30 Go

#SBATCH -J 04.Duplicates
#SBATCH -o 98_log_files/%x_%j.out
#SBATCH -e 98_log_files/%x_%j.err
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=18
#SBATCH --mem=68G
#SBATCH --time=00-01:00:00

set -e
# Load required modules
module load picard/3.1.1

# Global variables
MARKDUPS="MarkDuplicates"
ALIGNEDFOLDER="06_bam_files"
METRICSFOLDER="99_metrics"

# Copy script to log folder
TIMESTAMP=$(date +%Y-%m-%d_%Hh%Mm%Ss)
SCRIPT=$0
NAME=$(basename $0)
LOG_FOLDER="98_log_files"

export JAVA_TOOL_OPTIONS="-Xms2g -Xmx50g "
export _JAVA_OPTIONS="-Xms2g -Xmx50g "

# Fetch filename from the array
array=($(cut -f1 02_info_files/datatable.txt))
name=${array[0]}
file=${name}.sorted.bam

    echo "DEduplicatING sample $file"

    java -jar $PICARD $MARKDUPS \
        INPUT=$ALIGNEDFOLDER/$file \
        OUTPUT=$ALIGNEDFOLDER/${name}.dedup.bam \
        METRICS_FILE=$METRICSFOLDER/${name}_DUP_metrics.txt \
        VALIDATION_STRINGENCY=SILENT \
        REMOVE_DUPLICATES=true

echo " >>> Cleaning a bit...
"
echo "DONE! Go check your files."
