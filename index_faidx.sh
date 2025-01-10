#!/bin/bash

#SBATCH --nodes=1
#SBATCH --cpus-per-task=12
#SBATCH --partition=general
#SBATCH --qos=general
#SBATCH --mail-type=ALL
#SBATCH --mem=80G
#SBATCH --mail-user=meg.smith@ubc.ca
#SBATCH -o index_%j.out
#SBATCH -e index_%j.err 

module load samtools/1.20

samtools faidx intDF011.asm.hic.p_ctg.fasta
