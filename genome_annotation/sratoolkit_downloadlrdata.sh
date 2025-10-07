#!/bin/bash
#SBATCH -J sratoolkit
#SBATCH -p general
#SBATCH -q general
#SBATCH -n 1
#SBATCH -c 6
#SBATCH --mem=56G
#SBATCH --array=[0-3]
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

set -e
date
echo "[M]: Hostname"

home=/home/FCAM/msmith
scratch=/scratch/msmith
core=/core/projects/EBP/smith
outdir=${core}/genome_annotation_isoseq_data/raw_reads

module load sratoolkit/3.0.5
cd ${outdir}

all_accs=($(cat isoseq_accessions.txt))
acc=${all_accs[$SLURM_ARRAY_TASK_ID]}

echo "[M]: Downloading accession ${acc} (Slurm task ${SLURM_ARRAY_TASK_ID})"

#the core directory presently has more disk space than scratch, so using that

prefetch -v -O ${outdir}/"$acc" "$acc"
fasterq-dump -v -O ${outdir} -e 12 -t ${scratch} "$acc"
#remove the prefetch sra directory
rm -r ${outdir}/"$acc"
gzip "${acc}.fastq"

date
echo "[M]: Done. Bye!"
