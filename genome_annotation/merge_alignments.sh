#!/bin/bash
#SBATCH -J merge
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 24
#SBATCH --mem=250G
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

set -e
date
echo "[M]: Host Name: `hostname`"
module load samtools/1.19

alndir=/core/projects/EBP/smith/genome_annotation_shortread_data/alignments

cd ${alndir}

se_bams=$(ls *trim.bam)
pe_bams=$(ls *paired.bam)

samtools merge -@ 24 -o single_end_merged.bam ${se_bams} && rm *trim.bam
samtools merge -@ 24 -o paired_end_merged.bam ${pe_bams} && rm *paired.bam
