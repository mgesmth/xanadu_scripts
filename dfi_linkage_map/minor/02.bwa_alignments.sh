#!/bin/bash

#SBATCH -J 02.BWA
#SBATCH -o 98_log_files/%x_%A_%a.out
#SBATCH -e 98_log_files/%x_%A_%a.err
#SBATCH -c 8
#SBATCH --mem=48G

set -e
module load bwa/0.7.17 samtools/1.19 singularity/3.9.2

LOG_FOLDER="98_log_files"
INFO="02_info_files"
GENOMEFOLDER="03_genome"
GENOME=$(ls -1 $GENOMEFOLDER/*{fasta,fa,fasta.gz,fa.gz} | xargs -n 1 basename)
INDGENOME=${GENOME}.fai
RAWDATAFOLDER="05_trimmed_data"
ALIGNEDFOLDER="06_bam_files"
NCPU=$((${SLURM_CPUS_PER_TASK}-2))

array=($(cat $INFO/datatable.txt | cut -f1))
name=${array[$SLURM_ARRAY_TASK_ID]}

file1=${name}.R1.trimmed.fastq.gz
file2=${name}.R2.trimmed.fastq.gz
echo ">>> Aligning file $file1 $file2 <<<"

# Set ID
ID="@RG\tID:ind\tSM:ind\tPL:Illumina"

# Align reads
bwa mem -t $NCPU -R $ID $GENOMEFOLDER/$GENOME $RAWDATAFOLDER/$file1 $RAWDATAFOLDER/$file2 | samtools view -Sb -q 10 - > $ALIGNEDFOLDER/${name}.bam

# Sort
samtools sort --threads $NCPU $ALIGNEDFOLDER/${name}.bam > $ALIGNEDFOLDER/${name}.sorted.bam && rm $ALIGNEDFOLDER/${name}.bam

# Index
samtools index -c $ALIGNEDFOLDER/${name}.sorted.bam

echo "Done!"