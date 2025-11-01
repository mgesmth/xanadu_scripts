#!/bin/bash

head -n11 interior_primary_final_mancur_1Mb.fa.fai | awk '$1 ~ /HiC_scaffold_[0-9]+_1/ { print $2}' > index.tmp

idx=($(cat index.tmp))
touch sv_allele_summary_filt2_unbroken.tsv

for i in $(seq 1 6) ; do
  add=${idx[$i]}
  awk -v i=$i -v add=$add -v OFS="\t" '{
    scaffold=$1
    if (scaffold ~ "scaffold_"i"_1") {
      gsub(scaffold, "scaffold_"i)
      print scaffold,$2,$3,$4,$5,$6,$7,$8,$9
    } else if ($1 ~ "scaffold_"i"_2") {
      gsub($1, "scaffold_"i)
      new_start=$2+add
      new_end=$3+add
      print scaffold,new_start,new_end,$4,$5,$6,$7,$8,$9
    } else {
      next
    }
  }' sv_allele_summary_filt2.tsv >> sv_allele_summary_filt2_unbroken.tsv
done && rm index.tmp

awk '{
 scaffold=$1
 if (scaffold ~ /scaffold_[0-9]+_/) {
   next
 } else {
   print
 }
}' sv_allele_summary_filt2.tsv >> sv_allele_summary_filt2_unbroken.tsv
