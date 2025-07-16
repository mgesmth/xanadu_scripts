#!/bin/bash

alt_alt=$(awk '!/^#/ && $11 ~ "1:1" && $12 ~ "0:0" {print}' finalpangenome_filt2.sv.vcf | wc -l)
coast_alt=$(awk '!/^#/ && $11 ~ "0:0" && $12 ~ "1:1" {print}' finalpangenome_filt2.sv.vcf | wc -l)
same_alt=$(awk '!/^#/ && $11 ~ "1:1" && $12 ~ "1:1" {print}' finalpangenome_filt2.sv.vcf | wc -l)
two_alt=$(awk '!/^#/ && $11 ~ "1:1" && $12 ~ "2:2" {print}' finalpangenome_filt2.sv.vcf | wc -l)

echo -e "No. of SVs where alternate has only variant: ${alt_alt}"
echo -e "No. of SVs where coastal has only variant: ${coast_alt}"
echo -e "No. of SVs where both queries have the same variant: ${same_alt}"
echo -e "No. of SVs where both queries have different variants: ${two_alt}"
