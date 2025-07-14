#!/bin/bash
#SBATCH -J psmc_prep_tovcfarr
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 8
#SBATCH -n 1
#SBATCH --mem=15G
#SBATCH --array=[0-287]%100
#SBATCH -o %x.%a.%A.out
#SBATCH -e %x.%a.%A.err

set -e

echo "[M]: Host Name: `hostname`"

module load psmc/0.6.5
module load samtools/1.20
module load bcftools/1.19
module load tabix/0.2.6

home=/home/FCAM/msmith
scratch=/scratch/msmith
core=/core/projects/EBP/smith
bams=${scratch}/hifi_out
vcfs=${scratch}/vcfs
prim=${core}/CBP_assemblyfiles/interior_primary_final.fa

FILES=($(cat ${bams}/bams.txt))
BAM=${FILES[$SLURM_ARRAY_TASK_ID]}
VCFGZ=$(echo "$BAM" | sed 's/.bam/.vcf.gz/g')

date
echo "[M]: Welcome to task ${SLURM_ARRAY_TASK_ID}."
echo "[M]: We are transforming "$BAM" to "$VCFGZ""
echo "[M]: Beginning..."

bcftools mpileup -f "$prim" "${bams}/${BAM}" | bcftools call -c -Ov | \
bcftools sort -T ${scratch} | bgzip -c > "${vcfs}/${VCFGZ}"
bcftools tabix -p "vcf" "${vcfs}/${VCFGZ}"
if [[ $? -eq 0 ]] ; then
  date
  echo "[M]: File ${VCFGZ} created."
  exit 0
else
  date
  echo "[E]: File ${VCFGZ} not successfully created. Exiting 1."
  exit 1
fi
