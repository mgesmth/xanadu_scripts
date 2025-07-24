#!/bin/bash
#SBATCH -J alnhic_array
#SBATCH -p general
#SBATCH -q general
#SBATCH -n 1
#SBATCH -c 12
#SBATCH --mem=40G
#SBATCH -o %x.%A.%a.out
#SBATCH -e %x.%A.%a.err

set -e

date
echo "[M]: Host Name: `hostname`"
module load bwa/0.7.17
module load samtools/1.19

home=/home/FCAM/msmith
scratch=/scratch/msmith
core=/core/projects/EBP/smith
fq_dir=${scratch}/hic_split
bam_dir=${scratch}/hic_bams
#if [[ ! -d "$bam_dir" ]] ; then
#  mkdir "$bam_dir"
#fi
ref=${core}/CBP_assemblyfiles/interior_primary_final.fa
ref_name=$(basename ${ref})
#if [ ! -f "${assembly}.bwt" ]; then
#  echo "[M]: BWA index not found. Indexing..."
#  bwa index ${ref}
#  if [[ $? -ne 0 ]] ; then
#    echo "[E]: Indexing failed. Exit code $?."
#    exit 1
#  else
#    echo "[M]: Indexing complete."
#  fi
#fi

cd ${fq_dir}
r1=allhiC_R1.part_282.fastq.gz
r1_string="_R1"
name=${r1//$r1_string/}
r2=$(echo "$r1" | sed 's/R1/R2/')
out=$(echo "$r1" | sed 's/fastq.gz/bam/')
sampleName="HiC_sample"
libraryName="HiC_library"

rg="@RG\\tID:${name}\\tSM:${sampleName}\\tPL:LS454\\tLB:${libraryName}"

echo "[M]: Welcome to task ${SLURM_ARRAY_TASK_ID}."
echo "[M]: We are aligning ${r1} and ${r2} to ${ref_name}."

bwa mem -SP5M -t 4 -R "$rg" "$ref" "$r1" "$r2" | \
samtools sort -n -@ 4 -m 2500M -O "bam" -o "${bam_dir}/${out}"

if [[ $? -eq 0 ]] ; then
  date
  echo "[M]: Alignment complete. Removing fastqs for disk..."
  #rm "$r1" "$r2"
  if [[ $? -eq 0 ]] ; then
    echo "[M]: All cleaned up. Bye."
    exit 0
  else
    echo "[E]: Failed to remove fastqs."
    exit 1
  fi
else
  echo "[E]: Alignment failed. Exit code $?"
  date
  exit 1
fi
