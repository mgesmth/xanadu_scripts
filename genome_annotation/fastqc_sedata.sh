#!/bin/bash
#SBATCH -J fastqc
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 24
#SBATCH --mem=150G
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

set -e
date
echo "[M]: Host Name: `hostname`"

home=/home/FCAM/msmith
core=/core/projects/EBP/smith
scratch=/scratch/msmith
se_dir=${core}/se_reads
fastq_dir=${se_dir}/fastqc

module load fastqc/0.12.1
module load MultiQC/1.29

cd ${se_dir}
ls *.fastq.gz > files.tmp
files=$(cat files.tmp)
fastqc -o ${fastq_dir} -t 24 ${files}
cd ${fastq_dir}
multiqc .
rm ../files.tmp
