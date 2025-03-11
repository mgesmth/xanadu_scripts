#!/bin/bash
#SBATCH --partition=general
#SBATCH --qos=general
#SBATCH --cpus-per-task=12
#SBATCH --mem=150G
#SBATCH --mail-user=meg8130@student.ubc.ca
#SBATCH --mail-type=ALL
#SBATCH -o fastp.%j.out
#SBATCH -e fastp.%j.err

module load fastp/0.23.2

home=/home/FCAM/msmith
core=/core/projects/EBP/smith
indir=${core}/hiC_data
outdir=${home}/hiC_trim

fastp -i ${indir}/allhiC_R1.fastq.gz -I ${indir}/allhiC_R2.fastq.gz \
-o ${outdir}/allhiC_R1_trim.fastq.gz -O ${outdir}/allhiC_R2_trim.fastq.gz \
--adapter_sequence CTGTCTCTTATACACATCT --thread 36 --html
