#!/bin/bash
#SBATCH --partition=general
#SBATCH --qos=general
#SBATCH -c 12
#SBATCH --mem=100G
#SBATCH --mail-user=meg8130@student.ubc.ca
#SBATCH --mail-type=ALL
#SBATCH -o fastqc.%j.out
#SBATCH -e fastqc.%j.err

echo `hostname`
module load fastqc/0.12.1
module load MultiQC/1.10.1 

hiC_dir=/home/FCAM/msmith/hiC_data
scratch=/scratch/msmith

cd /home/FCAM/msmith/fastqc_out

fastqc -o ./ -t 12 -d /scratch/msmith ${hiC_dir}/allhiC_R1.fastq.gz ${hiC_dir}/allhiC_R2.fastq.gz
multiqc .

