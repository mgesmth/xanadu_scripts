#!/bin/bash
#SBATCH -J psmc_bootstrap
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 24
#SBATCH --mem=200G
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

echo "[M]: Host Name: `hostname`"

module load psmc/0.6.5

home=/home/FCAM/msmith
scratch=/scratch/msmith
psmcdir=${home}/psmc
bootstrap=${psmc}/bootstrap
splitpsmc=${bootstrap}/hifialn_merged_split.psmcfa

seq 100 | xargs -P 24 -I {} sh -c 'psmc -N25 -t15 -r5 -b -p "4+25*2+4+6" -o round-{}.psmc split.fa'

