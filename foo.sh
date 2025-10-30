#!/bin/bash


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
  ILLUMINACLIP:${adaptors}:2:30:10:2:keepBothReads \
  LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:30
done
