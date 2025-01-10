#!/bin/bash

#SBATCH --job-name=sra2fq
#SBATCH --nodes=1
#SBATCH --cpus-per-task=12
#SBATCH --partition=himem
#SBATCH --qos=himem
#SBATCH --mail-type=ALL
#SBATCH --mem=300G
#SBATCH --mail-user=meg.smith@ubc.ca
#SBATCH -o sra2fq_%j.out
#SBATCH -e sra2fq_%j.err

cd /home/FCAM/msmith/hiC_data
module load sratoolkit/3.0.5

fasterq-dump SRR30505304.sra
