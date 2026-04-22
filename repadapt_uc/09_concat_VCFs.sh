#!/bin/bash

#SBATCH --job-name="09.concatVCF"
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
VCF="07_raw_VCFs"
FILTVCF="08_filtered_VCFs"
FINALVCF="09_final_vcf"

begin=`date +%s`

cd ${FILTVCF}
ls -1 *_filtered.vcf.gz > look.txt
mkdir empty/
for file in $(cat look.txt) ; do
  l=$(zcat ${file} | awk -F "\t" '$0 ~ !/^#/ { print }' | wc -l)
  if [[ ${l} -eq 0 ]] ; then
    mv $file* empty/
  fi
done
cd ..

# Concatenate all the scaffold-VCF files into one global VCF file
bcftools concat $(ls -1 $FILTVCF/*_filtered.vcf.gz | perl -pe 's/\n/ /g') > ${FINALVCF}/${DATASET}_full_concatened.vcf && bgzip ${FINALVCF}/${DATASET}_full_concatened.vcf

# Add final maf filtering here...
bcftools view --min-af 0.01:minor ${FINALVCF}/${DATASET}_full_concatened.vcf.gz -Oz -o ${FILTVCF}/${DATASET}_full_concatened_maf01.vcf.gz
bcftools view --min-af 0.05:minor ${FINALVCF}/${DATASET}_full_concatened.vcf.gz -Oz -o ${FILTVCF}/${DATASET}_full_concatened_maf05.vcf.gz

echo "
DONE! Check you files"

end=`date +%s`
elapsed=`expr $end - $begin`
echo Time taken: $elapsed s
