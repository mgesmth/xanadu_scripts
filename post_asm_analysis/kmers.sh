#!/bin/bash
#SBATCH -J kmers
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 4
#SBATCH --mem=10G
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

set -e
date
echo "[M]: Host Name: `hostname`"

#variables
home=/home/FCAM/msmith
core=/core/projects/EBP/smith
scratch=/scratch/msmith
outdir=${core}/manual_curation_files
prim=${core}/3DDNA/mancur2/interior_primary_final_mancur2.fa
baseprim=$(basename ${prim})
alt=${core}/CBP_assemblyfiles/interior_alternate_final.fa

export PATH="${home}/scripts/post_asm_analysis:$PATH"
log=${core}/manual_curation_files/log

#Module files
module load R/4.2.2 meryl/1.4.1 merqury/1.3 java/17.0.2 samtools/1.20 bedtools/2.29.0
export PATH="/home/FCAM/msmith/R/x86_64-pc-linux-gnu-library/4.2:$PATH"
export PATH="/core/projects/EBP/smith/bin/genomescope2.0:$PATH"
#export MERQURY=/isg/shared/apps/merqury/1.3/merqury.sh
outmerq=${outdir}/merqury
outfix=prim_mancur_kmers
sub_merqury=${outmerq}/_submit_merqury.sh
meryldb=${core}/merqury_out/intDF_hifi_CBP.meryl
cd $outmerq

${sub_merqury} ${meryldb} ${prim} ${alt} ${outfix}
