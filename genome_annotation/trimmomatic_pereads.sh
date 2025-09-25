#!/bin/bash
#SBATCH -J trimmomatic
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 24
#SBATCH --mem=100G
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

##Adapted from: https://gitlab.com/douglas-fir-transcriptome/De-novo-assembly-of-short-reads/-/blob/De-novo-assembly/Trimmomatic1.sh?ref_type=heads

set -e
date
echo "[M]: Host Name: `hostname`"

home=/home/FCAM/msmith
scratch=/scratch/msmith
core=/core/projects/EBP/smith
pe_dir=${core}/genome_annotation_shortread_data/pe_reads
outdir=${core}/genome_annotation_shortread_data/pe_reads_trim
adaptors=${home}/transcriptome/00_process_sequencingdata/NEBNext_dual_adaptors.fasta

module load Trimmomatic/0.39

cd ${pe_dir}
ls -1 *R1.fastq.gz > files.tmp
for R1 in $(cat files.tmp) ; do
  R2=$(echo "$R1" | sed 's/_R1/_R2/g')
  base=${R1/_R1.fastq.gz/}

  java -Xmx100G -jar $Trimmomatic PE \
  -threads 24 -phred33 -trimlog ${outdir}/${base}_log \
  ${R1} ${R2} \
  ${outdir}/${base}_trim_R1_paired.fastq.gz \
  ${outdir}/${base}_trim_R1_unpaired.fastq.gz \
  ${outdir}/${base}_trim_R2_paired.fastq.gz \
  ${outdir}/${base}_trim_R2_unpaired.fastq.gz \
  ILLUMINACLIP:NEBNext_dual_adaptor.fasta:2:30:10:2:keepBothReads \
  LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:30
done
