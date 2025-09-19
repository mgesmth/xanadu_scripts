#!/bin/bash
#SBATCH -J sratoolkit
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 6
#SBATCH --mem=56G
#SBATCH --array=[0-26]
#SBATCH -o %x.%A.%a.out
#SBATCH -e %x.%A.%a.err

set -e
date
echo "[M]: Hostname"

home=/home/FCAM/msmith
scratch=/scratch/msmith
core=/core/projects/EBP/smith
outdir=${core}/se_reads

module load sratoolkit/3.0.5
cd ${outdir}

all_accs=($(cat failed_accs.txt))
acc=${all_accs[$SLURM_ARRAY_TASK_ID]}

echo "[M]: Downloading accession ${acc} (Slurm task ${SLURM_ARRAY_TASK_ID})"

#the core directory presently has more disk space than scratch, so using that

#fasterq-dump -v -O ${outdir} -e 6 -t ${scratch} "$acc"
#remove the prefetch sra directory
rm -r ${outdir}/"$acc"
gzip "${acc}.fastq"
