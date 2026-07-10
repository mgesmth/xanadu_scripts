#!/bin/bash

#SBATCH -J "07b.combinegvcfs_genotypegvcf"
#SBATCH -o 98_log_files/%x_%A_%a.out
#SBATCH -e 98_log_files/%x_%A_%a.err
#SBATCH -c 12
#SBATCH --mem=48G

DATASET=$1

# Load needed modules
module load GATK/4.5.0.0 singularity/3.9.2 tabix/0.2.6

# Global variables
LOG_FOLDER="98_log_files"
INFO="02_info_files"
GENOMEFOLDER="03_genome"
GENOME=$(ls -1 $GENOMEFOLDER/*{fasta,fa,fasta.gz,fa.gz} | xargs -n 1 basename)
INDGENOME=$GENOMEFOLDER/${GENOME}.fai
GVCF="07_gvcfs"
VCF="08_raw_vcfs"

ARRAY=($(cat 02_info_files/pos.txt))
REGION_FILE=02_info_files/${ARRAY[$SLURM_ARRAY_TASK_ID]}

sample_gvcfs=$(ls -1 $GVCF/*.vcf | paste -sd " ")
ls -1 $GVCF/*.vcf | awk '{print "-V",$1}' > argument_file.tmp

for scaff in $(cut -f1 $REGION_FILE) ; do

    gatk CombineGVCFs \
    -R $GENOMEFOLDER/$GENOME \
    -O $GVCF/${scaff}.g.vcf \
    -G StandardAnnotation \
    -G AS_StandardAnnotation \
    -L "$scaff" \
    --arguments_file argument_file.tmp

    gatk GenotypeGVCFs \
    -R $GENOMEFOLDER/$GENOME \
    -V $GVCF/${scaff}.g.vcf \
    -O $VCF/${scaff}.vcf.gz \
    -G StandardAnnotation \
    -G AS_StandardAnnotation \
    --create-output-variant-index false

tabix -p vcf $VCF/${scaff}.vcf.gz
bgzip $GVCF/${DATASET}.g.vcf

done

end=`date +%s`
elapsed=`expr $end - $begin`
echo Time taken: $elapsed
