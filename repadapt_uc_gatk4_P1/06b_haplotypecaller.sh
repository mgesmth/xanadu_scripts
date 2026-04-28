#!/bin/bash
# 1 CPU
# 30 Go

#SBATCH -J "06.HaplotypeCaller"
#SBATCH -o 98_log_files/%x_%A_array%a.out
#SBATCH -e 98_log_files/%x_%A_array%a.err
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=12
#SBATCH --mem=32G

set -e

#cd $SLURM_SUBMIT_DIR

# Copy script to log folder
TIMESTAMP=$(date +%Y-%m-%d_%Hh%Mm%Ss)
SCRIPT=$0
NAME=$(basename $0)
LOG_FOLDER="98_log_files"

# Load needed modules
module load samtools/1.19

# Uncomment these for big genomes
export JAVA_TOOL_OPTIONS="-Xms2g -Xmx32g "
export _JAVA_OPTIONS="-Xms2g -Xmx32g "

# Global variables
BAM="06_bam_files"
GVCF="07b_gvcfs"
GENOMEFOLDER="03_genome"
GENOME=$(ls -1 $GENOMEFOLDER/*{fasta,fa,fasta.gz,fa.gz} | xargs -n 1 basename)
#GENOME=/core/projects/EBP/smith/linkage_snp_calling/03_genome/interior_primary_final.FINAL.500kb_split.fa
INDGENOME=${GENOME}.fai
DATATABLE=02_info_files/datatable.txt

# Build Bam Index
echo " >>> Calling Haplotypes..."


# Fetch filename from the array
array_name=($(cut -f1 02_info_files/datatable.txt))
array_ploidy=($(cut -f2 02_info_files/datatable.txt))
name=${array_name[0]}
ploidy=${array_ploidy[0]}
file=${name}_RG.bam

    echo "
         >>> Realigning TARGET for $file <<<
         "

    # Now load modules
    module load GATK/4.5.0.0

    gatk HaplotypeCaller \
        -R $GENOMEFOLDER/$GENOME \
        -I $BAM/$file \
        --sample-ploidy ${ploidy} \
        -G StandardAnnotation \
        -G AS_StandardAnnotation \
        -G StandardHCAnnotation \
        -ERC GVCF \
        -O $GVCF/${name}.g.vcf

echo "
DONE! Check your files"
