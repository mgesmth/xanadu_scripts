#!/bin/bash
#SBATCH -J vsearch
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 12
#SBATCH --mem=48G
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=meg8130@student.ubc.ca
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

#Cluster transcripts based on similarity (0.95) from the multiple sources
#Second step of genome annotation (first is to concatenate all illumina transcripts, which was done in command line)
#adapted from https://gitlab.com/PlantGenomicsLab/genome-annotation-of-douglas-fir/-/blob/master/0_Transcriptome_Alignment/scripts/vsearch.sh?ref_type=heads

set -e
date
echo "[M]: Host Name: `hostname`"
dir=/home/FCAM/msmith/transcriptome/01_transcriptome_alignment
cat_fa=${dir}/cat_transcripts.fasta
centroids_out=${dir}/centroids_clustered.fasta
uc_out=${dir}/uc_clustered.uc

#Cluster search with VSearch
#module load vsearch/2.22.1
module load vsearch/2.22.1
vsearch --threads 12 --cluster_fast "$cat_fa" --centroids "$centroids_out" --uc "$uc_out" --id 0.95
