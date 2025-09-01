#!/bin/bash
#SBATCH -J postmancur_launch
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 1
#SBATCH --mem=2G
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

scripts=/home/FCAM/msmith/scripts/post_asm_analysis

#QUAST----
sbatch ${scripts}/quast.sh

#BUSCO----
sbatch ${scripts}/busco.sh eukaryota_odb12
sbatch ${scripts}/busco.sh viridiplantae_odb12
sbatch ${scripts}/busco.sh embryophyta_odb12

#KMERS----
sbatch ${scripts}/kmers.sh
