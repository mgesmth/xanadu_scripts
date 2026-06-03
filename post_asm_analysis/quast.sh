#!/bin/bash
#SBATCH -J quast
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 12
#SBATCH --mem=150G
#SBATCH -o /core/projects/EBP/smith/manual_curation_round2/log/%x.%j.out
#SBATCH -e /core/projects/EBP/smith/manual_curation_round2/log/%x.%j.err

home=/home/FCAM/msmith
core=/core/projects/EBP/smith
scratch=/scratch/msmith
outdir=${core}/final_genome
prim=${outdir}/psme_glauca_primary.fasta
baseprim=$(basename ${prim})
#alt=${core}/CBP_assemblyfiles/interior_alternate_final.fa

date
echo "[M]: Beginning QUAST analysis of ${baseprim}"
module load quast/5.2.0
quast=/isg/shared/apps/quast/5.2.0/quast.py
threads="$(getconf _NPROCESSORS_ONLN)"
outquast=${outdir}/quast

python3 $quast -t ${threads} --split-scaffolds --large -o ${outquast} ${prim}
