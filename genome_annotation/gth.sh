#!/bin/bash
#SBATCH -J gth
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 24
#SBATCH --mem=250G
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

set -e
date
echo "[M]: Host Name: `hostname`"

home=/home/FCAM/msmith
core=/core/projects/EBP/smith
asm=${core}/manual_curation_files/interior_primary_mancur_masked_500kb.fa
transcripts=${home}/transcriptome/02_braker_annotation/vsearch/all.95.centroids.80.centroids.fasta
protein_transcripts=${home}/transcriptome/02_braker_annotation/all.95.centroids.80.centroids.pep.fasta

gth \
-genomic ${asm} \
-cdna ${transcripts} \
-proteins ${protein_transcripts} \
-startcodon -finalstopcodon
#-prseedlength 20 -prhdist 2 -prminmatchlen 20 \
#-gcmincoverage 80 -gcmaxgapwidth 1000000 -dpminexonlen 20 \
-introncutout -skipalignmentout -force \
-exondistri -introndistri -refseqcovdistri \
-gff3out -o gth_trial_longreadaln.gff3

#prseedlength = specify seed length for protein matching (default 10); increasing it to 20 (default 10) increases the stringency of matches, I imagine - potentially good for large number of conifer genes?
#prhdist = maximum Hamming distance a protein match is allowed to have (a measure of how exact the match between sequences are): 2 is half the default, 4 which would allow more nucleotide mismatches between the transcript and putative gene
#prminmatchlen = length for initial matches used in similarity filter for protein matching (four less than default)
#gcmincoverage = minimum coverage for global chains, i.e, the proportion of the corresponding cDNA/protein sequence that must be matched by the global chain. Default is 50,
