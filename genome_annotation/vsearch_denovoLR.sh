#!/bin/bash
#SBATCH -J vsearch
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 12
#SBATCH --mem=48G
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

#Last step in De novo transcriptome assembly from long-reads
#adapted from https://gitlab.com/douglas-fir-transcriptome/de-novo-assembly-of-long-reads/-/blob/Reference-transcriptome/vsearch.sh

#IsoSeq transcripts were clustered at 95% sequence similarity within cells - this step clusters transcripts at 80% identity between cells

#This is needed for BRAKER annotation

set -e
date
echo "[M]: Host Name: `hostname`"

home=/home/FCAM/msmith
core=/core/projects/EBP/smith
trme=${home}/transcriptome
workdir=${trme}/02_braker_annotation/vsearch

cd ${workdir}

cat /core/labs/Wegrzyn/CoAdapTree_Douglasfir/IsoSeq/07_Vsearch/m54083_19051*/m54083_19051*.95.centroids.fasta > all.95.centroids.fasta

#this is the version used in the Velasco et al. workflow - recreating this step exactly so I have the exact same transcriptome
#Note this version is different from the one I used for the illumina read vsearch run - I used the most recent version there
module load vsearch/2.4.3

vsearch --threads 12 --log vsearch_denovoLR.log \
--cluster_fast all.95.centroids.fasta \
--id 0.8 \
--centroids all.95.centroids.80.centroids.fasta \
--uc all.95.centroids.80.clusters.uc

date
echo "[M]: Done."
