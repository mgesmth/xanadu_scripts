#!/bin/bash
#SBATCH -J split_hifi
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 12
#SBATCH --mem=48G
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

set -e
date
echo "[M]: Host Namer: `hostname`"

home=/home/FCAM/msmith
core=/core/projects/EBP/msmith
scratch=/scratch/msmith
hifi=/seqdata/EBP/plant/Pseudotsuga_menziesii/allhifi_merged_trimmed.fastq.gz
prx="hifi_split"
outdir=${scratch}/hifi_split
if [[ ! -d ${outdir}]] ; then
  mkdir ${outdir}
fi

module load seqkit/2.10.0

seqkit split2 ${hifi} -p 300 --by-part-prefix "$prx" -O ${outdir}
cd ${outdir}
ls *.fastq.gz > chunks.txt
