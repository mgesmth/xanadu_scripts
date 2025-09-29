#!/bin/bash
#SBATCH -J gFACs
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 24
#SBATCH --mem=250G
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

#Extract transcriptome alignment and filter
#Fifth step in genome annotation
#Adapted from https://gitlab.com/PlantGenomicsLab/genome-annotation-of-douglas-fir/-/blob/master/0_Transcriptome_Alignment/scripts/filtered_gfacs.sh?ref_type=heads

set -e
date
echo "[M]: Host Name: `hostname`"

home=/home/FCAM/msmith
core=/core/projects/EBP/smith
scratch=/scratch/msmith
mancur=${core}/manual_curation_files
asm=${core}/manual_curation_files/interior_primary_mancur_masked.fa
gfacs=${home}/transcriptome/01_transcriptome_alignment/gFACs/filtered
gmap=${home}/transcriptome/01_transcriptome_alignment/GMAP
if [[ ! -d ${gfacs} ]] ; then
  mkdir ${gfacs}
fi

module load gFACs/1.1.2
gfacs_script=/isg/shared/apps/gFACs/1.1.2/gFACs.pl

#filtering out non-uniqe genes, genes with CDS smaller than 300, genes without start and stop codons, genes with introns or exons smaller than 9 bp, and any genes with inframe stop codons (i.e., stop codon is not the last codon)

perl ${gfacs_script} \
-f gmap_2017_03_17_gff3 \
--statistics \
--unique-genes-only \
--min-CDS-size 300 \
--rem-genes-without-start-and-stop-codon \
--get-fasta \
--get-protein-fasta \
--allowed-inframe-stop-codons 0 \
--min-exon-size 9 \
--min-intron-size 9 \
--create-gtf --create-gff3 \
-p "intdf137_filtered" \
--fasta ${asm} \
-O ${gfacs}/ \
${gmap}/intdf137_gmap_genomeannotation_00.gff3
