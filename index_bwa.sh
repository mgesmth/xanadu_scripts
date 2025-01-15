#!/bin/bash

#SBATCH --nodes=1
#SBATCH --cpus-per-task=12
#SBATCH --partition=general
#SBATCH --qos=general
#SBATCH --mail-type=ALL
#SBATCH --mem=90G
#SBATCH --mail-user=meg.smith@ubc.ca
#SBATCH -o index_%j.out
#SBATCH -e index_%j.err 

module load bwa/0.7.17

bwa=/isg/shared/apps/bwa/0.7.17/bwa

$bwa index intDF011.asm.hic.p_ctg.fasta
