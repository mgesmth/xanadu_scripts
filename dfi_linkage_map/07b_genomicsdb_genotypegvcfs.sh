#!/bin/bash
# 1 CPU
# 30 Go

#SBATCH -J "07b.genomicsdb_genotypegvcf"
#SBATCH -o 98_log_files/%x_%A_array%a.out
#SBATCH -e 98_log_files/%x_%A_array%a.err
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=12G

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

    for scaf in $(cut -f1 $REGION_FILE)
    do
    echo ">>> Genotyping scaffold $scaf"


    gatk GenomicsDBImport \
    --genomicsdb-workspace-path $DB/$scaf \
    --batch-size 10 \
    -L $scaf \
    --sample-name-map 02_info_files/gvcfs_map \
    --reader-threads 8

    gatk GenotypeGVCFs \
    -R $GENOMEFOLDER/$GENOME \
    -V gendb://$DB/$scaf \
    -O $VCF/${scaf}.vcf.gz \
    -G StandardAnnotation \
    -G AS_StandardAnnotation


    done

end=`date +%s`
elapsed=`expr $end - $begin`
echo Time taken: $elapsed
