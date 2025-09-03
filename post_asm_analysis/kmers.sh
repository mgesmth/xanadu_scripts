#!/bin/bash
#SBATCH -J kmers
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 4
#SBATCH --mem=10G
#SBATCH -o ${log}/%x.%j.out
#SBATCH -e ${log}/%x.%j.err

set -e
date
echo "[M]: Host Name: `hostname`"

#variables
home=/home/FCAM/msmith
core=/core/projects/EBP/smith
scratch=/scratch/msmith
outdir=${core}/manual_curation_files
prim=${outdir}/interior_primary_final_mancur.fa
baseprim=$(basename ${prim})
alt=${core}/CBP_assemblyfiles/interior_alternate_final.fa

export PATH="${home}/scripts/post_asm_analysis:$PATH"
log=${core}/manual_curation_files/log

#Module files
module load R/4.2.2 meryl/1.4.1 merqury/1.3
export PATH="/home/FCAM/msmith/R/x86_64-pc-linux-gnu-library/4.2:$PATH"
export PATH="/core/projects/EBP/smith/bin/genomescope2.0:$PATH"
outmerq=${outdir}/merqury
outfix=${outmerq}/prim_mancur_kmers
sub_merqury=${outdir}/merqury/_submit_merqury.sh

${sub_merqury} "${outfix}.meryl" ${prim} ${alt} ${outfix}
if [[ $? -eq 0 ]] ; then
echo "[M]: Done."
exit 0
else
echo "[E]: Merqury run failed. Exit code $?"
fi
