#!/bin/bash
#SBATCH -J hifialn
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 10
#SBATCH --mem=80G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=meg8130@student.ubc.ca
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

echo '[M]: Host Name: `hostname`'

module load minimap2/2.28
module load samtools/1.20

home=/home/FCAM/msmith
core=/core/projects/EBP/smith
scratch=/scratch/msmith
prim=${core}/CBP_assemblyfiles/interior_primary_final.fa
hifi=${scratch}/test_hifi.fastq.gz
out=${scratch}/test_hifialn.bam

${home}/scripts/minimap2_hifi.sh -t 8 -r "$prim" -q "$hifi" -o "$out"
