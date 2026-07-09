#!/bin/bash

#SBATCH -J "06.HaplotypeCaller"
#SBATCH -o 98_log_files/%x_%A_%a.out
#SBATCH -e 98_log_files/%x_%A_%a.err
#SBATCH -c 12
#SBATCH --mem=32G

set -e

module load singularity/3.9.2 samtools/1.19

LOG_FOLDER="98_log_files"

export JAVA_TOOL_OPTIONS="-Xms2000M -Xmx${SLURM_MEM_PER_NODE}M "
export _JAVA_OPTIONS="-Xms2000M -Xmx${SLURM_MEM_PER_NODE}M "

# Global variables
BAM="06_bam_files"
GVCF="07_gvcfs"
GENOMEFOLDER="03_genome"
GENOME=$(ls -1 $GENOMEFOLDER/*{fasta,fa,fasta.gz,fa.gz} | xargs -n 1 basename)
INDGENOME=${GENOME}.fai
DATATABLE=02_info_files/datatable.txt

# Build Bam Index
echo " >>> Calling Haplotypes..."


# Fetch filename and ploidy from the array
array_name=($(cut -f1 hap_redo.txt))
#array_ploidy=($(cut -f2 02_info_files/datatable.txt))
name=${array_name[$SLURM_ARRAY_TASK_ID]}
#ploidy=${array_ploidy[$SLURM_ARRAY_TASK_ID]}
ploidy=1
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
