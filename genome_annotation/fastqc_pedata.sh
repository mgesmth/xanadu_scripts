#!/bin/bash
#SBATCH -J fastqc
#SBATCH -p general
#SBATCH -q general
#SBATCH -d afterok:792458
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
pe_dir=${core}/genome_annotation_shortread_data/pe_reads
fastq_dir=${pe_dir}/fastqc

module load fastqc/0.12.1
module load MultiQC/1.29

cd ${pe_dir}
ls *.fastq.gz > files.tmp
files=$(cat files.tmp)
fastqc -o ${fastq_dir} -t 24 ${files}
cd ${fastq_dir}
multiqc .
rm ../files.tmp
