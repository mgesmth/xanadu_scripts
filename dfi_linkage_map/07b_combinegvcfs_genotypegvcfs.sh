#!/bin/bash
# 1 CPU
# 30 Go

#SBATCH -J "07b.combinegvcfs_genotypegvcf"
#SBATCH -o 98_log_files/%x_%A_array%a.out
#SBATCH -e 98_log_files/%x_%A_array%a.err
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=36G

cd $SLURM_SUBMIT_DIR

# Copy script to log folder
TIMESTAMP=$(date +%Y-%m-%d_%Hh%Mm%Ss)
SCRIPT=$0
NAME=$(basename $0)
LOG_FOLDER="98_log_files"

begin=`date +%s`

# Load needed modules
module load GATK/4.5.0.0

# Global variables
INFO="02_info_files"
GENOMEFOLDER="03_genome"
GENOME=$(ls -1 $GENOMEFOLDER/*{fasta,fa,fasta.gz,fa.gz} | xargs -n 1 basename)
INDGENOME=$GENOMEFOLDER/${GENOME}.fai
GVCF="07b_gvcfs"
DB="08b_db"
VCF="09b_raw_vcfs"
# POP="02_info_files/popmap.txt"

ARRAY=($(cat 02_info_files/pos.txt))
REGION_FILE=02_info_files/${ARRAY[$SLURM_ARRAY_TASK_ID]}
scaf=$(cut -f1 $REGION_FILE)
sample_gvcfs=$(ls -1 $GVCF/*.g.vcf | awk -v ORS=" " '{print}')

    echo ">>> Genotyping scaffold $scaf"

    gatk CombineGVCFs \
    -R $GENOMEFOLDER/$GENOME \
    -V ${sample_gvcfs} \
    -O $GVCF/${DATASET}.g.vcf \
    -G StandardAnnotation \
    -G AS_StandardAnnotation 

    gatk GenotypeGVCFs \
    -R $GENOMEFOLDER/$GENOME \
    -V $GVCF/${DATASET}.g.vcf \
    -O $VCF/${DATASET}_unfiltered.vcf.gz \
    -G StandardAnnotation \
    -G AS_StandardAnnotation \
    --create-output-variant-index false



    done

end=`date +%s`
elapsed=`expr $end - $begin`
echo Time taken: $elapsed
