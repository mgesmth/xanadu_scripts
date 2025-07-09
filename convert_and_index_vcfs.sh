#!/bin/bash
#SBATCH -J convert
#SBATCH -p general
#SBATCH -q general
#SBATCH -n 1
#SBATCH -c 6
#SBATCH --mem=12G
#SBATCH --array=[0-286]%100
#SBATCH -o %x.%A.%a.out
#SBATCH -e %x.%A.%a.err

set -e
date
echo "[M]: Host Name: `hostname`"

module load bcftools/1.19
module load tabix/0.2.6

scratch=/scratch/msmith
vcfdir=${scratch}/vcfs

cd ${vcfdir}

FILES=($(cat files.txt))
VCF=${FILES[$SLURM_ARRAY_TASK_ID]}
newfile=$(echo "$VCF" | sed 's/.vcf.gz/.vcf.bgz/')

echo "[M]: Welcome to task ${SLURM_ARRAY_TASK_ID}. We are transforming ${VCF} to ${newfile}."

zcat ${VCF} | bgzip -c > ${newfile}
if [[ $? -eq 0 ]] ; then
  echo "[M]: File converted to bgzip compression. Removing original and indexing..."
  rm ${VCF}
  tabix ${newfile}
  if [[ $? -eq 0 ]] ; then
    date
    echo "[M]: gzip file removed and bgzip file indexed."
    exit 0
  else
    date
    echo "[E]: vcf file removal or indexing failed. Exiting 1."
    exit 1
  fi
else
  date
  echo "[E]: File not transformed to bgzip compression. Exiting 1."
  exit 1
fi


