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
outdir=${core}/genome_annotation_shortread_data/coastal_pe

module load sratoolkit/3.0.5
cd ${outdir}

echo "[M]: Downloading accession SRR12208320"
prefetch -v --max-size 100G -O ${outdir} "SRR12208320"
fasterq-dump -v -O ${outdir} -b 1GB -c 10GB -m 70GB -e 8 -t ${scratch} "SRR12208320"
rm -r ${outdir}/"SRR12208320"
gzip "SRR12208320_1.fastq"
gzip "SRR12208320_2.fastq"
