#!/bin/bash
#SBATCH -J hifialn
#SBATCH -p himem2
#SBATCH -q himem
#SBATCH -c 36
#SBATCH --mem=1000G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=meg8130@student.ubc.ca
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

echo '[M]: Host Name: `hostname`'

module load minimap2/2.28
module load samtools/1.20

home=/home/FCAM/msmith
core=/core/projects/EBP/smith
prim=${core}/CBP_assemblyfiles/interior_primary_final.fa
hifi=/seqdata/EBP/plant/Pseudotsuga_menziesii/allhifi_merged_trimmed.fastq.gz
out=/scratch/msmith/hifialn.bam

${home}/scripts/minimap2_hifi.sh -t 30 -r "$prim" -q "$hifi" -o "$out"
