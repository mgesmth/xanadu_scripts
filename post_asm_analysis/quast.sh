#!/bin/bash
#SBATCH -J quast
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 12
#SBATCH --mem=150G
#SBATCH -o /core/projects/EBP/smith/manual_curation_files/log/%x.%j.out
#SBATCH -e /core/projects/EBP/smith/manual_curation_files/log/%x.%j.err

home=/home/FCAM/msmith
core=/core/projects/EBP/smith
scratch=/scratch/msmith
outdir=${core}/manual_curation_files
prim=${outdir}/interior_primary_final_mancur2.fa
baseprim=$(basename ${prim})
alt=${core}/CBP_assemblyfiles/interior_alternate_final.fa
export PATH="${home}/scripts/post_asm_analysis:$PATH"
log=${core}/manual_curation_files/log

date
echo "[M]: Beginning QUAST analysis of ${baseprim}"
module load quast/5.2.0
quast=/isg/shared/apps/quast/5.2.0/quast.py
threads="$(getconf _NPROCESSORS_ONLN)"
outquast=${outdir}/quast

python3 $quast -t ${threads} --split-scaffolds --large -o ${outquast} ${prim}
if [[ $? -eq 0 ]] ; then
echo "[M]: Done."
exit 0
else
echo "[E]: QUAST run failed. Exit code $?"
fi
