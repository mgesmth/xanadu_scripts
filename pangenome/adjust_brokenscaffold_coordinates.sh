#!/bin/bash

head -n11 interior_primary_final_mancur_1Mb.fa.fai | awk '$1 ~ /HiC_scaffold_[0-9]+_1/ { print $2}' > index.tmp

idx=($(cat index.tmp))
touch sv_allele_summary_filt2_unbroken.tsv

for i in $(seq 1 6) ; do
  length=${idx[$i]}
  scaff_num=${i}
  add=$(echo $((${length}+200)))
  awk -v i=${scaff_num} -v add=$add -v OFS="\t" '{
    scaffold=$1
    if (scaffold ~ "HiC_scaffold_"i"_1") {
      gsub(scaffold, "scaffold_"i, $1)
      print
    } else if (scaffold ~ "HiC_scaffold_"i"_2") {
      gsub(scaffold, "scaffold_"i, $1)
      new_start=$2+add
      new_end=$3+add
      print $1,new_start,new_end,$4,$5,$6,$7
    } else {
      next
    }
  }' sv_allele_summary_filt2.tsv >> sv_allele_summary_filt2_unbroken.tsv
done && rm index.tmp

awk -v OFS="\t" '{
  scaffold=$1
  if (scaffold ~ /HiC_scaffold_[0-9]+_/){
    next
  } else if {
    gsub(/HiC_/,"",$1)
    print
  }
}' sv_allele_summary_filt2.tsv >> sv_allele_summary_filt2_unbroken.tsv
