#!/bin/bash
#SBATCH -J sratoolkit
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 12
#SBATCH --mem=64G
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

set -e
date
echo "[M]: Hostname"

home=/home/FCAM/msmith
scratch=/scratch/msmith
core=/core/projects/EBP/smith
outdir=${core}/se_reads

module load sratoolkit/3.0.5
cd ${outdir}

#Doing this in a loop instead of an array for two reasons:
## 1. It takes very little time to do an individual download, so not a huge concern
## 2. There is no way to automatically gzip the files as they are downloaded, and sending it to stdout and then to gzip doesn't seem to work. So doing it this way allows me to gzip them one at a time

for acc in $(cat SRR_accessionlist_cronn230libs.txt) ; do
  prefetch -v -O ${outdir}/"$acc" "$acc"
  fasterq-dump -v -O ${outdir} -e 12 -t ${scratch} "$acc"
  #remove the prefetch sra directory
  rm -r ${outdir}/"$acc"
  gzip "${acc}.fastq"
done
