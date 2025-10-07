#!/bin/bash
#SBATCH -J eviann
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 36
#SBATCH --mem=500G
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

set -e
date
echo "[M]: Host Name: `hostname`"

home=/home/FCAM/msmith
core=/core/projects/EBP/msmith
genome=${core}/manual_curation_files/interior_primary_mancur_masked_500kb.fa
transcript_file=${home}/transcriptome/02_braker_annotation/evidence_files.txt

export PATH="${core}/bin/EviAnn-2.0.4/bin:$PATH"
module load minimap2/2.28 hisat2/2.2.1 samtools/1.19
#all other dependencies are within the Eviann package itself

eviann.sh -t 36 -g ${genome} -r
