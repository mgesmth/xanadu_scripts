#!/bin/bash

module load vcftools/0.1.16 bcftools/1.23.1 bedtools/2.31.1 tabix/0.2.6
dir=/core/projects/EBP/smith/linkage_snp_calling/10b_filt_vcfs

cd ${dir}

vcftools --gzvcf linkage_snp_calling_gatk_filtered_pass_biallelic.vcf.gz \
--remove-indels --maf 0.0000001 \
--recode --recode-INFO-all \
--out linkage_snp_calling_gatk_filtered_pass_biallelic.snp.vcf
bgzip linkage_snp_calling_gatk_filtered_pass_biallelic.snp.recode.vcf

vcftools --gzvcf linkage_snp_calling_gatk_filtered_pass_biallelic.vcf.gz \
--keep-only-indels --maf 0.0000001 \
--recode --recode-INFO-all \
--out linkage_snp_calling_gatk_filtered_pass_biallelic.indel
bgzip linkage_snp_calling_gatk_filtered_pass_biallelic.indel.recode.vcf

bcftools view -h linkage_snp_calling_gatk_filtered_pass_biallelic.vcf.gz > header.txt

bedtools window -v -a linkage_snp_calling_gatk_filtered_pass_biallelic.snp.recode.vcf.gz \
-b linkage_snp_calling_gatk_filtered_pass_biallelic.indel.recode.vcf.gz \
-w 5 > variant.rm_indel_mark.vcf

cat header.txt variant.rm_indel_mark.vcf > linkage_snp_calling_gatk_filtered_pass_biallelic_indels.vcf | \
bgzip > linkage_snp_calling_gatk_filtered_pass_biallelic_indels.vcf.gz && rm header.txt variant.rm_indel_mark.vcf

tabix -p vcf linkage_snp_calling_gatk_filtered_pass_biallelic_indels.vcf.gz
