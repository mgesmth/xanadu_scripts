#!/bin/bash
#SBATCH -J 3DDNA_postreview
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 36
#SBATCH --mem=500G
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

set -e
date
echo "[M]: Host Name: `hostname`"

home=/home/FCAM/msmith
core=/core/projects/EBP/smith
scratch=/scratch/msmith
outdir=${core}/3DDNA
merge_nodups=${scratch}/juicer_formanualcur/work/intdf137/aligned/merged_nodups.txt
prim=${core}/CBP_assemblyfiles/interior_primary_final.fa
asm=${outdir}/interior_primary_final.0.review.assembly

export PATH="${core}/bin/3d-dna:$PATH"
module load gnu-parallel/20160622
module load java/22
export TMPDIR=${core}

cd ${outdir}

${core}/bin/3d-dna/run-asm-pipeline-post-review.sh -g 200 --sort-output -r ${asm} ${prim} ${merge_nodups}

if [[ $? -eq 0 ]] ; then
  echo "[M]: Post review pipeline complete. Bye!"
  exit 0
else
  echo "[E]: Post review pipeline failed. Exit code $?"
  exit 1
fi
