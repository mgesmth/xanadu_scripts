#!/bin/bash
#SBATCH -J gt_translate
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 8
#SBATCH --mem=24G
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

#translate de novo LR transcriptome to

set -e
date
echo "[M]: Host Name: `hostname`"

home=/home/FCAM/msmith
core=/core/projects/EBP/smith
scratch=/scratch/msmith
denovo_lr=${home}/transcriptome/02_braker_annotation/vsearch/all.95.centroids.80.centroids.fasta
out=${home}/transcriptome/02_braker_annotation/all.95.centroids.80.centroids.pep.fasta

module load genometools/1.6.2

gt seqtranslate -o ${out} ${denovo_lr}
