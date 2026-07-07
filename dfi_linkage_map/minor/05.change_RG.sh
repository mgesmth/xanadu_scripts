#!/bin/bash

#SBATCH -J 05.RG
#SBATCH -o 98_log_files/%x_%A_%a.out
#SBATCH -e 98_log_files/%x_%A_%a.err
#SBATCH -c 16
#SBATCH --mem=50G

set -e

module load picard/3.1.1 java/22 samtools/1.19 singularity/3.9.2

export JAVA_TOOL_OPTIONS="-Xms2000M -Xmx${SLURM_MEM_PER_NODE}M "
export _JAVA_OPTIONS="-Xms2000M -Xmx${SLURM_MEM_PER_NODE}M "

# Global variables
LOG_FOLDER="98_log_files"
INBAM="06_bam_files"
OUTBAM="06_bam_files"
ADDRG="AddOrReplaceReadGroups"
DATATABLE=02_info_files/datatable.txt

# Remove duplicates from bam alignments
echo "Editing RG...
"

# Fetch filename from the array
array=($(cut -f1 02_info_files/datatable.txt))
name=${array[$SLURM_ARRAY_TASK_ID]}
file=${name}.dedup.bam

# Fetch all our RG info...
new_RGSM=${name}

        echo "
             >>> Computing RG for $file<<<
             "
        java -jar $PICARD $ADDRG \
	    I=$INBAM/$file \
	    O=$OUTBAM/${name}_RG.bam \
	    RGID=${name} \
	    RGLB=${name}_LB \
	    RGPL=ILLUMINA \
	    RGPU=unit1 \
	    RGSM=${name}
        # Index
        echo "
            >>> Indexing ${name}_RG.bam <<<
            "
        samtools index -c $INBAM/${name}_RG.bam

echo "
DONE! Check your files"
