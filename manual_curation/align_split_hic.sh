#!/bin/bash
#SBATCH -J alnhic_array
#SBATCH -p general
#SBATCH -q general
#SBATCH -n 1
#SBATCH -c 8
#SBATCH --mem=20G
#SBATCH --array=[0-299]%50
#SBATCH -o %x.%j.%a.out
#SBATCH -e %x.%j.%a.err

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
if [[ ! -d "$bam_dir" ]] ; then
  mkdir "$bamdir"
fi
ref=${core}/CBP_assemblyfiles/interior_primary_final.fa
if [ ! -f "${assembly}.bwt" ]; then
  echo "[M]: BWA index not found. Indexing..."
  bwa index ${ref}
  if [[ $? -ne 0 ]] ; then
    echo "[E]: Indexing failed. Exit code $?."
    exit 1
  else
    echo "[M]: Indexing complete."
  fi
fi

cd ${fq_dir}
fqs=($(ls -1 allhiC_R1.*.fastq.gz))
r1=${fqs[$SLURM_ARRAY_TASK_ID]}
r2=$(echo "$r1" | sed 's/R1/R2/')
out=$(echo "$r1" | sed 's/fastq.gz/bam/' | sed 's/_R1//')

echo "[M]: Welcome to task ${SLURM_ARRAY_TASK_ID}."
echo "[M]: We are aligning ${r1} and ${r2} to ${ref}."

bwa mem -SP5M -t 4 "$ref" "$r1" "$r2" | \
samtools sort -n -@ 4 -m 2500M -O "bam" -o "$out" 

if [[ $? -eq 0 ]] ; then
  date
  echo "[M]: Alignment complete. Removing fastqs for disk..."
  rm "$r1" "$r2"
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
