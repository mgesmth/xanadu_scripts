#!/bin/bash

#SBATCH --job-name="09b.FiltVCF"
#SBATCH -o 98_log_files/%x_%j.out
#SBATCH -e 98_log_files/%x_%j.err
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=16G

module load GATK/4.5.0.0

cd $SLURM_SUBMIT_DIR

TIMESTAMP=$(date +%Y-%m-%d_%Hh%Mm%Ss)
SCRIPT=$0
NAME=$(basename $0)
LOG_FOLDER="98_log_files"
VCF="09b_raw_vcfs"
FILTVCF="10b_filt_vcfs"
GENOMEDIR="03_genome"
GENOME=$(ls -1 $GENOMEDIR/*{fasta,fa,fasta.gz,fa.gz} | xargs -n 1 basename)
echo "STARTING AT $TIMESTAMP"
echo $SCRIPT
begin=`date +%s`

gatk VariantFiltration \
-R $GENOMEDIR/$GENOME \
-V $VCF/${DATASET}_gatk_unfiltered.vcf \
-O $FILTVCF/${DATASET}_gatk_filtered.vcf.gz \
--filter-name "QualitybyDepth" --filter-expression "QD < 2.0" \
--filter-name "MappingQuality" --filter-expression "MQ < 40.0" \
--filter-name "StrandOddsRatio" --filter-expression "SOR > 3.0" \
--filter-name "FisherStrand" --filter-expression "FS > 60.0" \
--filter-name "MQRankSumTest" --filter-expression "MQRankSum < -12.5" \
--filter-name "ReadPosRankSum" --filter-expression "ReadPosRankSum < -8.0" \
--filter-name "Quality" --filter-expression "QUAL < 10.0"

echo "
DONE! Check you files"

end=`date +%s`
elapsed=`expr $end - $begin`
echo Time taken: $elapsed
