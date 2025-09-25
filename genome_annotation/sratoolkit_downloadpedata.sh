#!/bin/bash
#SBATCH -J sratoolkit
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 24
#SBATCH --mem=150G
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

set -e
date
echo "[M]: Hostname"

home=/home/FCAM/msmith
scratch=/scratch/msmith
core=/core/projects/EBP/smith
outdir=${core}/genome_annotation_shortread_data/pe_reads

module load sratoolkit/3.0.5
cd ${outdir}

#this is the list of the four accessions for the NovaSeq libraries
for acc in $(cat SraAccList.csv) ; do
  echo "[M]: Downloading accession ${acc}"
  prefetch -v --max-size 100G -O ${outdir}/"$acc" "$acc"
  fasterq-dump -v -O ${outdir} -e 8 -t ${scratch} "$acc"
  rm -r ${outdir}/"$acc"
  gzip "${acc}.fastq"
  echo "[M]: Done downloading ${acc}."
done

echo "[M]: All done. Bye!"
