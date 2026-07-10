#!/bin/bash

#SBATCH --job-name="08b.concatVCF"
#SBATCH -o 98_log_files/%x_%j.out
#SBATCH -e 98_log_files/%x_%j.err
#SBATCH -c 4
#SBATCH --mem=8G

set -e

module load singularity/3.9.2 vcftools/0.1.16 bcftools/1.19 tabix/0.2.6 

# Variables
DATASET=$1
VCF="08_raw_vcfs"
LOG_FOLDER="98_log_files"

# Concatenate all the scaffold-VCF files into one global VCF file
bcftools concat $(ls -1 $VCF/*.vcf.gz | perl -pe 's/\n/ /g') > ${VCF}/${DATASET}_unfiltered.vcf && bgzip ${VCF}/${DATASET}_unfiltered.vcf
tabix -p vcf ${VCF}/${DATASET}_unfiltered.vcf.gz

echo "
DONE! Check you files"