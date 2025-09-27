#!/bin/bash
#SBATCH -J trimmomatic
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 24
#SBATCH --mem=50G
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

##Based on the settings outlined in:
##Cronn, R., et al. (2017). Transcription through the eye of a needle: daily and annual cyclic gene expression variation in Douglas-fir needles. BMC Genomics, 18(1):558.
#Adapters are those from the TruSeq single index (as stated in Cronn et al. methods):
#https://support-docs.illumina.com/SHARE/AdapterSequences/Content/SHARE/AdapterSeq/TruSeq/SingleIndexes.htm

set -e
date
echo "[M]: Host Name: `hostname`"

home=/home/FCAM/msmith
scratch=/scratch/msmith
core=/core/projects/EBP/smith
se_dir=${core}/genome_annotation_shortread_data/se_reads
outdir=${core}/genome_annotation_shortread_data/se_reads_trim
adapters=${home}/transcriptome/00_process_sequencingdata/NEBNext_dual_adaptors.fasta

module load Trimmomatic/0.39
module load java/22

cd ${se_dir}
ls -1 *R1.fastq.gz > files.tmp
for fastq in $(cat files.tmp) ; do
  base=${fastq/.fastq.gz/}

  java -Xmx50G -jar $Trimmomatic SE \
  -threads 24 -phred33 -trimlog ${outdir}/${base}_log \
  ${fastq} ${outdir}/${base}_trim.fastq.gz \
  ILLUMINACLIP:${adapters}:2:30:10:2 \
  LEADING:20 TRAILING:20 SLIDINGWINDOW:5:20
done
