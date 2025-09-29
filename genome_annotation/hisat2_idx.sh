#!/bin/bash
#SBATCH -J hisat2_idx
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 12
#SBATCH --mem=64G
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

set -e
date
echo "[M]: Host Name: `hostname`"

home=/home/FCAM/msmith
core=/core/projects/EBP/smith
scratch=/scratch/msmith
splitdir=${core}/manual_curation_files/mancur_masked_split
hisatdir=${home}/transcriptome/02_braker_annotation/hisat2/masked_idx
scaffolds=$(cat ${splitdir}/names_rightorder_500kb.csv)
#names_rightorder_500kb is a comma-separated list of files containing scaffolds larger than 500kb, 1 to 251, which were split using seqkit split

cd ${hisatdir}
hisat2-build -p 12 -f ${scaffolds} "interior_primary_mancur_masked"
