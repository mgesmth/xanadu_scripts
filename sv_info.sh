#!/bin/bash

alt_alt=$(awk '!/^#/ && $11 ~ "1:1" && $12 ~ "0:0" {print}' finalpangenome_filt.sv.vcf | wc -l)
coast_alt=$(awk '!/^#/ && $11 ~ "0:0" && $12 ~ "1:1" {print}' finalpangenome_filt.sv.vcf | wc -l)
same_alt=$(awk '!/^#/ && $11 ~ "1:1" && $12 ~ "1:1" {print}' finalpangenome_filt.sv.vcf | wc -l)
two_alt=$(awk '!/^#/ && $11 ~ "1:1" && $12 ~ "2:2" {print}' finalpangenome_filt.sv.vcf | wc -l)

sum=$(echo $((${alt_alt}+${coast_alt}+${same_alt}+${two_alt})))
echo ""
echo -e "No. of SVs where alternate has only variant: ${alt_alt}"
echo -e "No. of SVs where coastal has only variant: ${coast_alt}"
echo -e "No. of SVs where both queries have the same variant: ${same_alt}"
echo -e "No. of SVs where both queries have different variants: ${two_alt}"
echo ""

awk 'BEGIN { OFS="\t" } !/^#/ { split($8, m, ";") ; print $1,$2,substr(m[1],5)}' finalpangenome_filt.sv.vcf > filtered_coordinates.bed 
bedtools intersect -a interior_alternate_1Mb.bed -b filtered_coordinates.bed -wa -F 1 > interior_alternate_1Mb_filt.bed 
bedtools intersect -a coastal_1Mb.bed -b filtered_coordinates.bed -wa -F 1 > coastal_1Mb_filt.bed 
bedtools intersect -a interior_primary_bigscaffoldsplit.bed -b filtered_coordinates.bed -wa -F 1 > interior_primary_bigscaffoldsplit_filt.bed 
bedtools intersect -a finalpangenome.bed -b filtered_coordinates.bed -wa -F 1 > finalpangenome_filt.bed

awk 'BEGIN { OFS = "\t" } {split($6,m,":") ; print m[2]}' interior_alternate_1Mb_filt.bed > alt_allele_len.tmp
awk 'BEGIN { OFS = "\t" } {split($6,m,":") ; print m[2]}' interior_primary_bigscaffoldsplit_filt.bed > prim_allele_len.tmp
awk 'BEGIN { OFS = "\t" } {split($6,m,":") ; print m[2]}' coastal_1Mb_filt.bed > coast_allele_len.tmp
#field 6 has 0 if no inversion, 1 if inversion
cut -f 6 finalpangenome_filt.bed > inversion.tmp 

echo -e "scaffold\tstart\tend\talt_allele\tcoast_allele\tprim_length\talt_length\tcoast_length\tinversion" > sv_allele_summary.tsv
awk 'BEGIN { OFS="\t" } !/^#/ {
split($8,m,";")
#genotypes, by default, have the form 0:0. just one haplotype, so I just want one num, i.e. 0 (substr($11,3))
print $1,$2,substr(m[1],5),substr($11,3),substr($12,3)}' finalpangenome_filt.sv.vcf | \
paste - prim_allele_len.tmp alt_allele_len.tmp coast_allele_len.tmp >> sv_allele_summary.tsv

