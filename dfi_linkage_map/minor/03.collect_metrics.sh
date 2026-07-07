#!/bin/bash

#SBATCH -J 03.Metrics
#SBATCH -o 98_log_files/%x_%A_%a.out
#SBATCH -e 98_log_files/%x_%A_%a.err
#SBATCH -c 1
#SBATCH --mem=10G

set -e
module load picard/3.1.1 singularity/3.9.2

# Global variables
GENOMEFOLDER="03_genome"
GENOME=$(ls -1 $GENOMEFOLDER/*{fasta,fa,fasta.gz,fa.gz} | xargs -n 1 basename)
ALIGNEDFOLDER="06_bam_files"
METRICSFOLDER="99_metrics"
ALIGN="CollectAlignmentSummaryMetrics"
INSERT="CollectInsertSizeMetrics"
COVERAGE="CollectWgsMetricsWithNonZeroCoverage"
LOG_FOLDER="98_log_files"

    # Fetch filename from the array

    array=($(cut -f1 02_info_files/datatable.txt))
    name=${array[$SLURM_ARRAY_TASK_ID]}
    bamfile=${name}.sorted.bam

    echo \n">>> Computing alignment metrics for $file <<<"\n
    java -jar $PICARD $ALIGN \
        R=$GENOMEFOLDER/$GENOME \
        I=$ALIGNEDFOLDER/$bamfile \
        O=$METRICSFOLDER/${name}_alignment_metrics.txt

    echo \n">>> Computing insert size metrics for $file <<<"\n
    java -jar $PICARD $INSERT \
        I=$ALIGNEDFOLDER/$bamfile \
        OUTPUT=$METRICSFOLDER/${name}_insert_size_metrics.txt \
        HISTOGRAM_FILE=$METRICSFOLDER/${name}_insert_size_histogram.pdf

    echo \n">>> Computing coverage metrics for $file <<<"\n
    java -jar $PICARD $COVERAGE \
        R=$GENOMEFOLDER/$GENOME \
        I=$ALIGNEDFOLDER/$bamfile \
        OUTPUT=$METRICSFOLDER/${name}_collect_wgs_metrics.txt\
        CHART=$METRICSFOLDER/${name}_collect_wgs_metrics.pdf

echo \n">>> DONE! <<<"\n
