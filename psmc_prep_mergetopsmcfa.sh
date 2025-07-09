#!/bin/bash
#SBATCH -J psmc_prep_mergetopsmcfa
#SBATCH -p himem2
#SBATCH -q himem
#SBATCH -c 36
#SBATCH --mem=1200G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=meg8130@student.ubc.ca
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

set -e

echo "[M]: Host Name: `hostname`"

home=/home/FCAM/msmith
core=/core/projects/EBP/smith
scratch=/scratch/msmith
vcfs=${scratch}/vcfs
out=

module load vcftools/0.1.16

cd ${vcfs}
vcf_files=$(ls -1 *.vcf.gz | paste -sd ' ')

