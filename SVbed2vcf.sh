#!/bin/bash
#SBATCH -J bed2vcf
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 8
#SBATCH --mem=50G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=meg8130@student.ubc.ca
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

echo `hostname`

