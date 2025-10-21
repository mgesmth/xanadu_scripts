#!/bin/bash
#SBATCH -J hisat2
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 36
#SBATCH --mem=500G
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

set -e
date
echo "[M]: Host Name: `hostname`"

home=/home/FCAM/msmith
scratch=/scratch/msmith
core=/core/projects/EBP/smith
idx=${home}/transcriptome/02_braker_annotation/hisat2/masked_idx/interior_primary_mancur_masked
petrimdir=${core}/genome_annotation_shortread_data/pe_reads_trim
outdir=${core}/genome_annotation_shortread_data/alignments
if [[ ! -d $outdir ]] ; then
  mkdir $outdir
fi

cd $outdir

module load hisat2/2.2.1
module load samtools/1.19

ls ${petrimdir}/*_trim_R1_paired.fastq.gz > pe_trim.txt

for R1 in $(cat pe_trim.txt) ; do
  R2=$(echo "$R1" | sed 's/_R1/_R2/g')
  base=$(basename ${R1/_trim_R1_paired.fastq.gz/})
  hisat2 -p 18 --max-intronlen 2000000 -x ${idx} -1 ${R1} -2 ${R2} | \
  samtools sort -m 2G -@ 18 -O bam -o ${outdir}/${base}_paired.bam
done && rm pe_trim.txt

pe_bams=$(ls *paired.bam)
samtools merge -@ 36 -o paired_end_merged.bam ${pe_bams} && rm *paired.bam
