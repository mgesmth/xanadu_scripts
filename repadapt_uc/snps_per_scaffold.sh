#!/bin/bash


for scaff in $(cat major_scaffolds_split.txt) ; do
  awk -F "\t" -v scaff="$scaff" '$0 ~ /^#/ {
  next
} $1 == scaff {
  print }' linkage_snp_calling_full_concatened_maf05_major.vcf | wc -l >> snps_per_scaffold.txt
done

paste -d "\t" major_scaffolds_split.txt snps_per_scaffold.txt > snps_per_scaffold_split.tsv && rm snps_per_scaffold.txt

awk '{split($1,m,"_") ; print "scaffold_" m[2] "_primary"}' major_scaffolds_split.txt | uniq > major_scaffolds.txt

for scaff in $(cat major_scaffolds.txt) ; do
  awk -F "\t" -v scaff="$scaff" '$0 ~ /^#/ {
  next
} $1 ~ scaff {
  print }' linkage_snp_calling_full_concatened_maf05_major.vcf | wc -l >> snps_per_scaffold.txt
done
