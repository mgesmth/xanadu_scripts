#!/bin/bash
#SBATCH -J bam2hints
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 24
#SBATCH --mem=150G
#SBATCH -d afterok:833169
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

set -e
date
echo "[M]: Host Name: `hostname`"

home=/home/FCAM/msmith
home_workdir=${home}/transcriptome/02_braker_annotation
core=/core/projects/EBP/smith
alndir=${core}/genome_annotation_shortread_data/alignments

cd ${alndir}

module load augustus/3.6.0
export AUGUSTUS_CONFIG_PATH=${home_workdir}/config

#cranking up max intron size - chose this number based on the largest intron sizes from the Velasco paper
bam2hints --in single_end_merged.bam --out single_end_hints.gff \
--maxintronlen 850000
