#!/bin/bash
#SBATCH -J create_iterator
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 1
#SBATCH --mem=1G
#SBATCH -d afterok:9365832
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

#create a list to iterate over for merge array
cd /scratch/msmith/hifi_out
ls *.bam > bams.txt
