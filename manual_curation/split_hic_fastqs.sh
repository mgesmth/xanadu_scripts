#!/bin/bash
#SBATCH -J split_hic_fastqs
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 18
#SBATCH --mem=200G
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

set -e

date
echo "[M]: Host Name: `hostname`"

home=/home/FCAM/msmith
core=/core/projects/EBP/smith
scratch=/scratch/msmith
R1=${home}/hiC_data/allhiC_R1.fastq.gz
R2=${home}/hiC_data/allhiC_R2.fastq.gz
outdir=${scratch}/hic_split
if [[ ! -d "$outdir" ]] ; then
  mkdir ${outdir}
fi
splitN=300

module load seqkit/2.10.0

echo "[M]: Splitting ${R1} and ${R2} into ${splitN} parts..."

seqkit split2 -1 "$R1" -2 "$R2" -p "$splitN" -O "$outdir" -f
if [[ $? -eq 0 ]] ; then
  echo "[M]: Splitting complete."
  exit 0
else
  echo "[M]: Splitting failed. Exit code $?"
  date
  exit 1
fi
