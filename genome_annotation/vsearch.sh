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

set -e
date
echo "[M]: Host Name: `hostname`"
dir=/home/FCAM/msmith/transcriptome/01_transcriptome_alignment
cat_fa=${dir}/cat_transcripts.fasta
centroids_out=${dir}/centroids_clustered_2.4.3.fasta
uc_out=${dir}/uc_clustered_2.4.3.uc

#Cluster search with VSearch
#module load vsearch/2.22.1
module load vsearch/2.4.3
vsearch --threads 12 --cluster_fast "$cat_fa" --centroids "$centroids_out" --uc "$uc_out" --id 0.95
