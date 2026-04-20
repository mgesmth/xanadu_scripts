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
GENOME=$(ls -1 $GENOMEFOLDER/*{fasta,fa,fasta.gz,fa.gz} | xargs -n 1 basename)
echo "STARTING AT $TIMESTAMP"
echo $SCRIPT
begin=`date +%s`

gatk VariantFiltration \
-R $GENOMEDIR/$GENOME \
-V $VCF/${DATASET}_gatk_unfiltered.vcf.gz \
-O $FILTVCF/${DATASET}_gatk_filtered.vcf.gz \
--filterName "QualitybyDepth" --filterExpression "QD < 2.0" \
--filterName "MappingQuality" --filterExpression "MQ < 40.0" \
--filterName "StrandOddsRatio" --filterExpression "SOR > 3.0" \
--filterName "FisherStrand" --filterExpression "FS > 60.0" \
--filterName "MQRankSumTest" --filterExpression "MQRankSum < -12.5" \
--filterName "ReadPosRankSum" --filterExpression "ReadPosRankSum < -8.0" \
--filterName "Quality" --filterExpression "QUAL < 10.0"

echo "
DONE! Check you files"

end=`date +%s`
elapsed=`expr $end - $begin`
echo Time taken: $elapsed
