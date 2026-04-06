
#!/bin/bash

#SBATCH -J 05.RG
#SBATCH -o 98_log_files/%x_%j.out
#SBATCH -e 98_log_files/%x_%j.err
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=50G

set -e

#cd $SLURM_SUBMIT_DIR

# Copy script to log folder
TIMESTAMP=$(date +%Y-%m-%d_%Hh%Mm%Ss)
SCRIPT=$0
NAME=$(basename $0)
LOG_FOLDER="98_log_files"
cp "$SCRIPT" "$LOG_FOLDER"/"$TIMESTAMP"_"$NAME"

# Load needed modules - ComputeCanada clusters
module load picard
module load java
module load samtools/1.20

export JAVA_TOOL_OPTIONS="-Xms2g -Xmx50g "
export _JAVA_OPTIONS="-Xms2g -Xmx50g "

# Global variables
INBAM="06_bam_files"
OUTBAM="06_bam_files"
ADDRG="AddOrReplaceReadGroups"
#PICARD=$EBROOTPICARD/picard.jar
DATATABLE=02_info_files/datatable.txt

# Remove duplicates from bam alignments
echo "Editing RG...
"

# Fetch filename from the array
array=($(cut -f1 02_info_files/datatable.txt))
name=${array[0]}
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

echo " >>> Cleaning a bit...
"
echo "
DONE! Check your files"
