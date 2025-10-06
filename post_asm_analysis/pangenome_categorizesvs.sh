#!/bin/bash
#SBATCH -J categorize_svs
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 8
#SBATCH --mem=48G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=meg8130@student.ubc.ca
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

date
set -e
echo "[M]: Host Name: `hostname`"
echo "[M]: Beginning categorization of SVs"

home=/home/FCAM/msmith
core=/core/projects/EBP/smith
scratch=/scratch/msmith
prim=${core}/manual_curation_files/interior_primary_final_mancur_1Mb.fa
alt=${core}/CBP_assemblyfiles/interior_alternate_1Mb.fa
coast=${core}/coastal/coastalDF_scaffrenamed_sorted_1Mb.fa
prx="final_finalpangenome"
outdir=${core}/manual_curation_files/minigraph

module load python/3.8.1
cd ${core}/manual_curation_files/minigraph
cat_svs=${home}/scripts/categorize_svs.py

python ${cat_svs} "${prx}_filtered1.sv.vcf" \
"${prx}_primcall_verified.bed" \
"${prx}_altcall_verified.bed" \
"${prx}_coastcall_verified.bed" \
"${prx}_verified.bed" \
"svs_categorized.tsv"

if [[ $? -eq 0 ]] ; then
  echo "[M]: Done."
  exit 0
else
  echo "[E]: SV Categorization failed. Exit code $?"
  exit 1
fi
