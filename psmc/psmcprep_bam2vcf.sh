#!/bin/bash
#SBATCH -J psmc_bam2vcf
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 8
#SBATCH -n 1
#SBATCH --mem=15G
#SBATCH --array=[0-287]%100
#SBATCH -d afterok:<ITERATOR>
#SBATCH -o %x.%a.%A.out
#SBATCH -e %x.%a.%A.err

set -e
date
echo "[M]: Host Name: `hostname`"

#Module files
module load psmc/0.6.5
module load samtools/1.20
module load bcftools/1.19
module load tabix/0.2.6

#Variables
home=/home/FCAM/msmith
scratch=/scratch/msmith
core=/core/projects/EBP/smith
prim=${core}/manual_curation_files/interior_primary_final_mancur2.fa
hifi_aln=${scratch}/hifi_out
vcf_dir=${scratch}/hifi_vcfs

FILES=($(cat ${hifi_aln}/bams.txt))
BAM=${FILES[$SLURM_ARRAY_TASK_ID]}
VCFGZ=$(echo "$BAM" | sed 's/.bam/.vcf.gz/g')

echo "[M]: Welcome to task ${SLURM_ARRAY_TASK_ID}."
echo "[M]: We are transforming "$BAM" to "$VCFGZ""
echo "[M]: Beginning..."

bcftools mpileup -q 30 -Q 30 -f "$prim" "${bams}/${BAM}" | bcftools call -c -Ov | \
bcftools sort -T ${scratch}/msmith/sortb | bgzip -c > "${vcfs}/${VCFGZ}"
if [[ $? -eq 0 ]] ; then
  date
  echo "[M]: VCF created. Indexing..."
  bcftools index -p "vcf" "${vcfs}/${VCFGZ}"
  if [[ $? -eq 0 ]] ; then
    echo "[M]: Index created. Bye!"
    exit 0
  else
    echo "[E]: Index creation failed. Exiting."
    exit 1
  fi
else
  date
  echo "[E]: VCF conversion failed. Exiting."
  exit 1
fi
