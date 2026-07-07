#!/bin/bash

#SBATCH -J 01.fastp
#SBATCH -o 98_log_files/%x_%A_%a.out
#SBATCH -e 98_log_files/%x_%A_%a.err
#SBATCH -c 6
#SBATCH --mem=10G

set -e
module load fastp/0.23.4

# Variables
INDIR="04_raw_data"
OUTDIR="05_trimmed_data"
LOG="98_log_files"
if [[ $SLURM_ARRAY_TASK_ID == 0 ]] ; then
mkdir $OUTDIR/01_reports
fi

# Pull file from the FASTP_ARRAY
array=($(cut -f1 02_info_files/datatable.txt))
name=${array[$SLURM_ARRAY_TASK_ID]}

# Run over file
    #input_file=$(echo "$file" | perl -pe 's/_R1.*\.fastq.gz//')
    echo "Still working for you... Cleaning: $name"

    fastp -w ${SLURM_CPUS_PER_TASK} \
        -i $INDIR/${name}_R1.fastq.gz \
        -I $INDIR/${name}_R2.fastq.gz \
        -o $OUTDIR/"$name".R1.trimmed.fastq.gz \
        -O $OUTDIR/"$name".R2.trimmed.fastq.gz \
        -j $OUTDIR/01_reports/"$name".json \
        -h $OUTDIR/01_reports/"$name".html \
        &> "$LOG"/01_fastp_"$name"_"$TIMESTAMP".out
