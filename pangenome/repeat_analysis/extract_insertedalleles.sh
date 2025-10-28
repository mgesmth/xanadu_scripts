#!/bin/bash

set -e

home=/home/FCAM/msmith
core=/core/projects/EBP/smith
scratch=/scratch/msmith
mg_dir=${core}/minigraph
bed_filt=${mg_dir}/final_finalpangenome_filtered.bed
#there's one more filtering step in cat_svs, so this file has the full correct coordinates
svs_cat=${mg_dir}/svs_categorized.tsv
threshold=$1

module load bedtools/2.29.0

cd ${mg_dir}

cut -f1-3 ${svs_cat} > filtered2_coordinates.bed
#apply the second filter to the bed file
bedtools intersect -F 1 -wa -a ${bed_filt} -b filtered2_coordinates.bed > final_finalpangenome_filtered2.bed
#reset bedfile
bed_filt=${mg_dir}/final_finalpangenome_filtered2.bed

cd repeat_masker_dir

mkdir byscaffold_svs_${threshold}
cd byscaffold_svs_${threshold}
#Create a fasta file containing the long allele for each variant per scaffold
for scaffold in $(cut -f1 ${bed_filt} | uniq) ; do
  grep -w "$scaffold" ${bed_filt} | \
  awk -v scaffold="$scaffold" '{if ($6 == 0) {
    print ">"scaffold"_sv"NR ORS $14
    } else {
    next
    }}' > ${scaffold}_svs.fasta
done && ls -1 *_svs.fasta > fasta_files.iterator

#create an error directory for extra stuff
mkdir extra_and_error
