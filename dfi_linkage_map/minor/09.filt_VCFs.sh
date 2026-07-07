#!/bin/bash

#SBATCH --job-name="09b.FiltVCF"
#SBATCH -o 98_log_files/%x_%j.out
#SBATCH -e 98_log_files/%x_%j.err
#SBATCH -c 8
#SBATCH --mem=16G

set -e

module load vcftools/0.1.16 bcftools/1.23.1 bedtools/2.31.1 tabix/0.2.6 GATK/4.5.0.0 singularity/3.9.2

LOG_FOLDER="98_log_files"
VCF="08_raw_vcfs"
FILTVCF="09_filt_vcfs"
GENOMEDIR="03_genome"
GENOME=$(ls -1 $GENOMEDIR/*{fasta,fa,fasta.gz,fa.gz} | xargs -n 1 basename)
DATASET=$1

gatk VariantFiltration \
-R $GENOMEDIR/$GENOME \
-V $VCF/${DATASET}_unfiltered.vcf.gz \
-O $FILTVCF/${DATASET}_filtered.vcf.gz \
--filter-name "AlleleDepth" --filter-expression "DP < 10" \
--filter-name "QualitybyDepth" --filter-expression "QD < 2.0" \
--filter-name "MappingQuality" --filter-expression "MQ < 50.0" \
--filter-name "StrandOddsRatio" --filter-expression "SOR > 3.0" \
--filter-name "FisherStrand" --filter-expression "FS > 60.0" \
--filter-name "MQRankSumTest" --filter-expression "MQRankSum < -12.5" \
--filter-name "ReadPosRankSum" --filter-expression "ReadPosRankSum < -8.0" \
--filter-name "Quality" --filter-expression "QUAL < 20.0" \
--create-output-variant-index false

tabix -p vcf $FILTVCF/${DATASET}_filtered.vcf.gz


#only move forward with variants that pass
zcat $FILTVCF/${DATASET}_filtered.vcf.gz | awk -F "\t" -v OFS="\t" '{
  if ($0 ~ /^#/) {
    print
  } else if ($7 == "PASS") {
    print
  } else {
    next
  }
}' > $FILTVCF/${DATASET}_filtered_pass.vcf && bgzip $FILTVCF/${DATASET}_filtered_pass.vcf

tabix -p vcf $FILTVCF/${DATASET}_filtered_pass.vcf.gz

#biallelic snps
gatk SelectVariants \
-V $FILTVCF/${DATASET}_filtered_pass.vcf.gz \
-O $FILTVCF/${DATASET}_filtered_pass_biallelic.vcf.gz \
--exclude-filtered TRUE --restrict-alleles-to BIALLELIC \
--create-output-variant-index false

tabix -p vcf $FILTVCF/${DATASET}_filtered_pass_biallelic.vcf.gz

#FILTER SNPS AROUND INDELS
#isolate SNPs
vcftools --gzvcf $FILTVCF/${DATASET}_filtered_pass_biallelic.vcf.gz \
--remove-indels --maf 0.0000001 \
--recode --recode-INFO-all \
--out $FILTVCF/${DATASET}_filtered_pass_biallelic.snp
bgzip $FILTVCF/${DATASET}_filtered_pass_biallelic.snp.recode.vcf

#isolate indels
vcftools --gzvcf $FILTVCF/${DATASET}_filtered_pass_biallelic.vcf.gz \
--keep-only-indels --maf 0.0000001 \
--recode --recode-INFO-all \
--out $FILTVCF/${DATASET}_filtered_pass_biallelic.indel
bgzip $FILTVCF/${DATASET}_filtered_pass_biallelic.indel.recode.vcf

#get the header
bcftools view -h $FILTVCF/${DATASET}_filtered_pass_biallelic.vcf.gz > $FILTVCF/header.txt

#print records that don't overlap with indels or 5bp in either direction
bedtools window -v -a $FILTVCF/${DATASET}_filtered_pass_biallelic.snp.recode.vcf.gz \
-b $FILTVCF/${DATASET}_filtered_pass_biallelic.indel.recode.vcf.gz \
-w 5 > $FILTVCF/variant.rm_indel_mark.vcf

#put filtered records and header together
cat $FILTVCF/header.txt $FILTVCF/variant.rm_indel_mark.vcf > $FILTVCF/${DATASET}_filtered_pass_biallelic_indels.vcf
rm $FILTVCF/header.txt $FILTVCF/variant.rm_indel_mark.vcf $FILTVCF/${DATASET}_filtered_pass_biallelic.indel.recode.vcf.gz $FILTVCF/${DATASET}_filtered_pass_biallelic.snp.recode.vcf.gz

#filter by missingness, GQ and allele depth
ind_missingness=0.9
snp_missingness=0.25
gq=99
in_vcf=$FILTVCF/${DATASET}_filtered_pass_biallelic_indels.vcf
out_vcf=$FILTVCF/${DATASET}_filtered_pass_biallelic_indels_missingness${snp_missingness}_gq${gq}.vcf

python3 ${scripts}/filter_GQ_missingness_maternal_allowhomozyg.py \
${snp_missingness} ${ind_missingness} ${gq_std} "$in_vcf" "$out_vcf"
mv missingness_per* ${FILTVCF}/
mv inds_passed* ${FILTVCF}/

bgzip $FILTVCF/${DATASET}_filtered_pass_biallelic_indels.vcf
tabix -p vcf $FILTVCF/${DATASET}_filtered_pass_biallelic_indels.vcf.gz

echo "
DONE! Check you files"

