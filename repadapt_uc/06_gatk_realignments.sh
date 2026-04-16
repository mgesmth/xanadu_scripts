#!/bin/bash
# 1 CPU
# 30 Go

#SBATCH -J "06.ReAlignmentS"
#SBATCH -o 98_log_files/%x_%A_array%a.out
#SBATCH -e 98_log_files/%x_%A_array%a.err
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=12
#SBATCH --mem=32G
#SBATCH --time=00-168:00:00

set -e

#cd $SLURM_SUBMIT_DIR

# Copy script to log folder
TIMESTAMP=$(date +%Y-%m-%d_%Hh%Mm%Ss)
SCRIPT=$0
NAME=$(basename $0)
LOG_FOLDER="98_log_files"
cp "$SCRIPT" "$LOG_FOLDER"/"$TIMESTAMP"_"$NAME"

# Load needed modules
module load samtools/1.19

# Uncomment these for big genomes
export JAVA_TOOL_OPTIONS="-Xms2g -Xmx32g "
export _JAVA_OPTIONS="-Xms2g -Xmx32g "

# Global variables
BAM="06_bam_files"
GENOMEFOLDER="03_genome"
GENOME=$(ls -1 $GENOMEFOLDER/*{fasta,fa,fasta.gz,fa.gz} | xargs -n 1 basename)
INDGENOME=${GENOME}.fai
DATATABLE=02_info_files/datatable.txt

# Build Bam Index
echo " >>> Realigning...
"


# Fetch filename from the array
array=($(cut -f1 02_info_files/datatable.txt))
name=${array[$SLURM_ARRAY_TASK_ID]}
file=${name}_RG.bam

    echo "
         >>> Realigning TARGET for $file <<<
         "

    # Now load modules
    module load GATK/3.7

    # Realign
    java -jar $GATK \
        -T RealignerTargetCreator \
        -R $GENOMEFOLDER/$GENOME \
        -I $BAM/$file \
        -o $BAM/${name}.intervals

    echo "
         >>> Realigning INDELs for $file <<<
         "
    java -jar $GATK \
        -T IndelRealigner \
        -R $GENOMEFOLDER/$GENOME \
        -I $BAM/$file \
        -targetIntervals $BAM/${name}.intervals \
        --consensusDeterminationModel USE_READS  \
        -o $BAM/${name}.realigned.bam

echo ">>> Cleaning a bit...
"
echo "
DONE! Check your files"
