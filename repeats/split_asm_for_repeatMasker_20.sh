#!/bin/bash
#SBATCH -J splitasm
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 6
#SBATCH --mem=30G
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

set -e
echo "[M]: Host Name: `hostname`"

home=/home/FCAM/msmith
core=/core/projects/EBP/smith
scratch=/scratch/msmith
primary=${core}/manual_curation_files/interior_primary_mancur.fa

#find where the first 20 scaffolds end in fasta file and send to tmp 20 scaffold file, and all else to another file
awk '{if ($1 ~ "scaffold_21") { ; print NR-1 ; exit }}' ${primary} > linenum.tmp
linenum=$(tr -d '\n' < linenum.tmp)
head -n ${linenum} ${primary} > ${scratch}/20_tmp.fa
totallen=$(wc -l ${primary} | cut -d ' ' -f1)
tailnum=$(echo $((${totallen}-${linenum})))
tail -n ${tailnum} ${primary} > ${scratch}/allelse_tmp.fa
rm linenum.tmp
#split rest of scaffolds into above 1Mb and below 1Mb - will be run in separate slurm arrays
if [[ ! -f "${scratch}/allelse_tmp.fa.fai" ]] ; then
  module load samtools/1.19
  samtools faidx "${scratch}/allelse_tmp.fa.fai"
  module unload samtools/1.19
fi
awk '{
  if ($2 > 1000000) { 
    prevline=1 
  } else if ($2 < 1000000 && prevline=1) {
    print $1
    exit
  }
}' "${scratch}/allelse_tmp.fa.fai" > first_small_scaffold.tmp
scaffnum=$(tr -d '\n' < first_small_scaffold.tmp)
awk -v scaffnum="$scaffnum" '{if ($1 ~ scaffnum) { ; print NR-1 ; exit }}' ${scratch}/allelse_tmp.fa > linenum1.tmp
linenum1=$(tr -d '\n' < linenum1.tmp)
head -n ${linenum1} ${scratch}/allelse_tmp.fa > ${scratch}/above1Mb_tmp.fa
totallen1=$(wc -l ${scratch}/allelse_tmp.fa | cut -d ' ' -f1)
tailnum1=$(echo $((${totallen1}-${linenum1})))
tail -n ${tailnum1} ${scratch}/allelse_tmp.fa > ${scratch}/below1Mb_tmp.fa
rm ${scratch}/allelse_tmp.fa

#split the tmp fasta files into 20 parts for each scaffold
module load seqkit/2.10.0
seqkit split -s 1 ${scratch}/20_tmp.fa --by-size-prefix "interior_primary_mancur_scaffold" -O ${scratch}/repeatMasker_20
rm ${scratch}/20_tmp.fa

#for 



