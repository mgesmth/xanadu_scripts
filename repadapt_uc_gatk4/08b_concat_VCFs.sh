#!/bin/bash

#SBATCH --job-name="08b.concatVCF"
#SBATCH -o 98_log_files/%x_%j.out
#SBATCH -e 98_log_files/%x_%j.err
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=8G

module load vcftools/0.1.16 bcftools/1.19
module load tabix/0.2.6

cd $SLURM_SUBMIT_DIR

TIMESTAMP=$(date +%Y-%m-%d_%Hh%Mm%Ss)
SCRIPT=$0
NAME=$(basename $0)
LOG_FOLDER="98_log_files"
echo $SCRIPT

# Variables
VCF="09b_raw_vcfs"

begin=`date +%s`

# Concatenate all the scaffold-VCF files into one global VCF file
bcftools concat $(ls -1 $FILTVCF/*.vcf.gz | perl -pe 's/\n/ /g') > ${VCF}/${DATASET}_gatk_unfiltered.vcf && bgzip ${FILTVCF}/${DATASET}_gatk_unfiltered.vcf

echo "
DONE! Check you files"

end=`date +%s`
elapsed=`expr $end - $begin`
echo Time taken: $elapsed s
