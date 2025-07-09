#!/bin/bash
#SBATCH -J psmc_prep_mergetopsmcfa
#SBATCH -p himem2
#SBATCH -q himem
#SBATCH -c 36
#SBATCH --mem=1200G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=meg8130@student.ubc.ca
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

set -e

echo "[M]: Host Name: `hostname`"

home=/home/FCAM/msmith
core=/core/projects/EBP/smith
scratch=/scratch/msmith
vcfs=${scratch}/vcfs
out_vcf=${scratch}/hifialn_merged2.vcf.gz
out_fastq=${scratch}/hifialn_merged2.fastq.gz
out_psmcfa=${home}/hifialn_merged2.psmcfa

module load vcftools/0.1.16
module load psmc/0.6.5

cd ${vcfs}
vcf_files=$(ls -1 *.vcf.bgz | paste -sd ' ')

vcf-merge -d ${vcf_files} | vcf-sort -c -p 24 | bgzip -c > "$out_vcf"
rm *.vcf.bgz *.tbi
cd ..
vcfutils.pl vcf2fq -d 10 -D 100 "$out_vcf" | gzip -c > "$out_fastq"
rm ${out_vcf}
fq2psmcfa -q20 "$out_fastq" > "$out_psmcfa"


