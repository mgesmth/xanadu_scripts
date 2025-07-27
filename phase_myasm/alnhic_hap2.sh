#!/bin/bash
#SBATCH -J alnhic_hap1
#SBATCH -p general
#SBATCH -q general
#SBATCH -n 1
#SBATCH -c 8
#SBATCH --mem=20G
#SBATCH --array=[0-299]
#SBATCH -o %x.%A.%a.out
#SBATCH -e %x.%A.%a.err

set -e 
date
echo "[M]: Host Name: `hostname`"

home=/home/FCAM/msmith
core=/core/projects/EBP/smith
scratch=/scratch/msmith
hap2_ctg=${home}/yahs/contigs/intDF011.asm.hic.hap2.p_ctg.fasta
hic_split=${scratch}/hic_split
hic_splitout=${scratch}/hic_hap2/split

module load bwa/0.7.17
module load samtools/1.19

cd ${hic_split}
hic_fastqs=($(cat files.txt))
R1=${hic_fastqs[$SLURM_ARRAY_TASK_ID]}
R2=$(echo "$R1" | sed 's/R1/R2/')
base=$(basename "$hap1_ctg")
name=${R1//_R1/}
out=$(echo "$name" | sed 's/fastq.gz/bam/')

echo "[M]: Welcome to task $SLURM_ARRAY_TASK_ID. We are aligning ${R1} and ${R2} to ${base}."

bwa mem -SP5M -t 4 -R "$hap1_ctg" "$R1" "$R2" | \
samtools sort -n -@ 4 -m 2500M -O "bam" -o "${hic_splitout}/${out}"

if [[ $? -eq 0 ]] ; then
  if [[ $? -eq 0 ]] ; then
  date
  echo "[M]: Alignment complete. Removing fastqs for disk..."
  rm "$R1" "$R2"
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
