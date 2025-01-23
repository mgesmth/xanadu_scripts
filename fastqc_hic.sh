#!/bin/bash
##SBATCH --job-name=fastqc_hic
##SBATCH --partition=general
##SBATCH --qos=general
##SBATCH --nodes=1
##SBATCH --cpus-per-task=12
##SBATCH --mem=100G
##SBATCH --mail-type=ALL
##SBATCH --mail-user=meg8130@student.ubc.ca
##SBATCH -o fastqc_hic_%j.out
##SBATCH -e fastqc_hic_%j.err

echo `hostname`
module load fastqc/0.12.1

hiC_dir=/home/FCAM/msmith/hiC_data
scratch=/scratch/msmith

fastqc -t 12 -d /scratch/msmith allhiC_R1.fastq.gz allhiC_R2.fastq.gz 

