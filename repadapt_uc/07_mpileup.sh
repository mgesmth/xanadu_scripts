#!/bin/bash
# 1 CPU
# 30 Go

#SBATCH -J "07.mpileup"
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
cp $SCRIPT $LOG_FOLDER/${TIMESTAMP}_${NAME}

begin=`date +%s`

# Load needed modules
module load bcftools/1.23.1 gnu-parallel/20160622

# Global variables
INFO="02_info_files"
GENOMEFOLDER="03_genome"
GENOME=$(ls -1 $GENOMEFOLDER/*{fasta,fa,fasta.gz,fa.gz} | xargs -n 1 basename)
INDGENOME=$GENOMEFOLDER/${GENOME}.fai
VCF="./07_raw_VCFs"
# POP="02_info_files/popmap.txt"
BAM="02_info_files/bammap.txt"
PLD="02_info_files/ploidymap.txt"
ARRAY=($(cat 02_info_files/pos.txt))
REGION_FILE=02_info_files/${ARRAY[$SLURM_ARRAY_TASK_ID]}

    for scaf in $(cut -f1 $REGION_FILE)
    do
    echo ">>> Genotyping scaffold $scaf"
    done

#ok
#mpileup:
##-Ou = output as uncompressed bcf
## -q 5 = min mapping quality of 5
## -r {} = .. I think this is allowing us to important the scaffold which we are calling on this thread, given the fact that the output file has {} and, when actually outputted, the file has the name of the scaffold
## -I = skip calling indels
## -a FMT/AD = include allelic depth in INFO field of output

#call:
## -S $PLD = sample list containing ploidy info
## -G - = this is essentially turning off assumptions of HWE
## -m = use alternate multiallelic caller model (apparently -c, the other, is limited in some ways)
## -v = call variant sites only
## -Ov = output as uncompressed vcf

    # Action!
    parallel -j8 "bcftools mpileup -Ou -f $GENOMEFOLDER/$GENOME --bam-list $BAM -q 5 -r {} -I -a FMT/AD | bcftools call -S $PLD -G - -f GQ -mv -Ov > $VCF/${DATASET}_{}.vcf" :::: $REGION_FILE

end=`date +%s`
elapsed=`expr $end - $begin`
echo Time taken: $elapsed
