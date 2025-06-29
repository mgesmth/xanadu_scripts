#!/bin/bash
#SBATCH -J psmc
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 36
#SBATCH --mem=250G
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

set -e 

echo '[M]: Host Name: `hostname`'

home=/home/FCAM/msmith
core=/core/projects/EBP/smith
scratch=/scratch/msmith
psmcdir=${home}/psmc
psmcfa=${psmcdir}/hifialn_merged.psmcfa
split_psmcfa=${psmcdir}/hifialn_merged_split.psmcfa

module load psmc/0.6.5

splitfa "$psmcda" > "$split_psmcfa"

psmc -r1 -p "2+2+25*2+4+6" -o "${psmcdir}/interior_trial1.psmc" "$psmcfa"

