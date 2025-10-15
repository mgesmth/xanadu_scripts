#!/bin/bash

home=/home/FCAM/msmith
core=/core/projects/EBP/smith
scratch=/scratch/msmith
mg_dir=${core}/manual_curation_files/minigraph
pangenome=${mg_dir}/final_finalpangenome.gfa
bed_filt=${mg_dir}/final_finalpangenome_filtered.bed
#there's one more filtering step in cat_svs, so this file has the full correct coordinates
svs_cat=${mg_dir}/svs_categorized.tsv

module load bedtools/2.29.0

cd ${mg_dir}

cut -f1-3 svs_categorized.tsv > filtered2_coordinates.bed
#apply the second filter to the bed file
bedtools intersect -F 1 -wa -a ${bed_filt} -b filtered2_coordinates.bed > final_finalpangenome_filtered2.bed
#reset bedfile
bed_filt=${mg_dir}/final_finalpangenome_filtered2.bed

#create a working directory
mkdir repeat_masker_dir
cd repeat_masker_dir

mkdir byscaffold_svs
for scaffold in $(cut -f1 ${bed_filt} | uniq) ; do
  grep -w "$scaffold" ${bed_filt} | \
  awk -v OFS="\t" '{print NR,$1,$2,$3}' > byscaffold_svs/${scaffold}_svs.tmp
done




#extract the segments involved in each SV
cut -f1,12 ${bed_filt} > segments_scaffolds.tmp
#break into one file per scaffold for repeat masker parallelization
mkdir segment_scaffolds
for scaffold in $(cut -f1 segments_scaffolds.tmp | uniq) ; do
  #grab only the lines corresponding to that scaffold (whole word, -w) and add an index, i.e., number the SVs
  grep -w "$scaffold" segments_scaffolds.tmp | \
  awk -v OFS="\t" '{ print NR,$0 }' > segment_scaffolds/segments_${scaffold}.tmp
done && rm segments_scaffolds.tmp

cd segment_scaffolds
for file in $(ls -1 *.tmp) ; do
  sv_num=$(cut -f1 ${file})
  scaffold=$(cut -f2 ${file})
  seq_name=">${scaffold}_sv${sv_num}"
  segments=$(cut -f3 ${file})
  gfatools view -l ${segments}
