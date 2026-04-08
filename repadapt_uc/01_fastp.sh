#!/bin/bash
# 6 CPUs
# 10 Go

#SBATCH -J 01.fastp
#SBATCH -o 98_log_files/%x_%j.out
#SBATCH -e 98_log_files/%x_%j.err
#SBATCH -c 6
#SBATCH --mem=10G

set -e
# Load up fastp
module load fastp/0.23.2

#cd $SLURM_SUBMIT_DIR

##Keep some info. about the run/script
TIMESTAMP=$(date +%Y-%m-%d_%Hh%Mm%Ss)
SCRIPT=$0
NAME=$(basename $0)

# Variables
INDIR="04_raw_data"
OUTDIR="05_trimmed_data"
LOG="98_log_files"
TIMESTAMP=$(date +%Y-%m-%d_%Hh%Mm%Ss)
mkdir $OUTDIR/01_reports

# Make a log file to the species log directory
cp $SCRIPT $LOG/"$TIMESTAMP"_"$NAME"

# Pull file from the FASTP_ARRAY
array=($(cut -f1 02_info_files/datatable.txt))
name=${array[0]}

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
