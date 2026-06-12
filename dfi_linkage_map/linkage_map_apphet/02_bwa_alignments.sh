#!/bin/bash

#SBATCH -J 02.BWA
#SBATCH -o 98_log_files/%x_%A_%a.out
#SBATCH -e 98_log_files/%x_%A_%a.err
#SBATCH -c 8
#SBATCH --mem=48G

set -e

# Load needed modules
module load bwa/0.7.17 samtools/1.19 singularity/3.9.2

##Keep some info. about the run/script
TIMESTAMP=$(date +%Y-%m-%d_%Hh%Mm%Ss)
SCRIPT=$0
NAME=$(basename $0)
LOG_FOLDER="98_log_files"

# Global variables
GENOMEFOLDER="03_genome"
GENOME=$(ls -1 $GENOMEFOLDER/*{fasta,fa,fasta.gz,fa.gz} | xargs -n 1 basename)
INDGENOME=${GENOME}.fai
RAWDATAFOLDER="05_trimmed_data"
ALIGNEDFOLDER="06_bam_files"
TIMESTAMP=$(date +%Y-%m-%d_%Hh%Mm%Ss)

# Test if user specified a number of CPUs
if [[ -z "$NCPU" ]]
then
    NCPU=4
fi

# If this is our first run, make a list of all the trimmed reads for cleaning
ls -1 $RAWDATAFOLDER/*R1.trimmed.fastq.gz | xargs -n 1 basename | sed 's/.R1.trimmed.fastq.gz//g' > $RAWDATAFOLDER/all_trimmed_ids.txt

array=($(cat $RAWDATAFOLDER/all_trimmed_ids.txt))
name=${array[$SLURM_ARRAY_TASK_ID]}

# Set ID
ID="@RG\tID:ind\tSM:ind\tPL:Illumina"

# Align reads
bwa mem -t $NCPU -R $ID $GENOMEFOLDER/$GENOME $RAWDATAFOLDER/$file1 $RAWDATAFOLDER/$file2 | samtools view -Sb -q 10 - > $ALIGNEDFOLDER/${name}.bam

# Sort
samtools sort --threads $NCPU $ALIGNEDFOLDER/${name}.bam > $ALIGNEDFOLDER/${name}.sorted.bam && rm $ALIGNEDFOLDER/${name}.bam

# Index
samtools index -c $ALIGNEDFOLDER/${name}.sorted.bam

echo "Done!"
