#!/bin/bash
#!/bin/bash
# Submit scripts from the $SPECIES_DIR directory

core=/core/projects/EBP/smith

# Variables
# Name of general working directory
MAIN=${core}
# Name of directory where snp calling is happening
DATASET="redo_P1"
SPECIES_DIR=$MAIN/$DATASET
cd $SPECIES_DIR

# Point to directory where scripts are
PIPE_DIR="01_scripts"

# Set metadata
DATATABLE=$SPECIES_DIR/02_info_files/datatable.txt

# Set Email for slurm reports
EMAIL="meg8130@student.ubc.ca"

LR_PARTITION="general"
HR_PARTITION="himem"
LR_QOS="general"
HR_QOS="himem"


# How many samples are there?
#FASTQ_N=$( ls $SPECIES_DIR/04_raw_data/*fastq.gz | wc -l )
#  FILE_ARRAY=$(( $(($FASTQ_N / 2))-1 ))

job00=$(sbatch -p ${LR_PARTITION} -q ${LR_QOS} \
-D $SPECIES_DIR \
--mail-type=ALL \
--mail-user=$EMAIL \
--parsable \
$PIPE_DIR/00a_prep_genome.sh)

'''
##########################
# Part 1 of the pipeline #
##########################
'''

# Trim
job01=$(sbatch -p ${LR_PARTITION} -q ${LR_QOS} \
--dependency=afterok:${job00} \
   -D $SPECIES_DIR \
   --mail-type=ALL \
   --mail-user=$EMAIL \
   --parsable \
   $PIPE_DIR/01_fastp.sh)

# Index reference & Align reads to reference
# Note - If fastq files include .1 and .2 suffixes, bwa will fail. Lines in script 02 can be commented out to handle this
job02=$(sbatch -p ${LR_PARTITION} -q ${LR_QOS} \
   --dependency=afterok:$job01 \
   -D $SPECIES_DIR \
   --mail-type=ALL \
   --mail-user=$EMAIL \
   --parsable \
   $PIPE_DIR/02_bwa_alignments.sh)

# Collect sample data metrics
job03=$(sbatch -p ${LR_PARTITION} -q ${LR_QOS} \
   --dependency=afterok:$job02 \
   -D $SPECIES_DIR \
   --mail-type=ALL \
   --mail-user=$EMAIL \
   --parsable \
   $PIPE_DIR/03_collect_metrics.sh)

'''
##########################
# Part 2 of the pipeline #
##########################
'''

# Remove duplicates
job04=$(sbatch -p ${LR_PARTITION} -q ${LR_QOS} \
--dependency=afterok:${job03} \
   -D $SPECIES_DIR \
   --mail-type=ALL \
   --mail-user=$EMAIL \
   --parsable \
   $PIPE_DIR/04_remove_duplicates.sh)


# Change bam files RG
job05=$(sbatch -p ${LR_PARTITION} -q ${LR_QOS} \
   --dependency=afterok:$job04 \
   -D $SPECIES_DIR \
   --mail-type=ALL \
   --mail-user=$EMAIL \
   --parsable \
   $PIPE_DIR/05_change_RG.sh)

'''
##########################
# Part 3 of the pipeline #
##########################
'''

# New step here now to merge BAM files over samples...
# Count the number of unique samples in $DATATABLE

# Haplotype Caller
job06=$(sbatch -p ${LR_PARTITION} -q ${LR_QOS} \
--dependency=afterok:${job05} \
   -D $SPECIES_DIR \
   --mail-type=ALL \
   --mail-user=$EMAIL \
   --parsable \
   $PIPE_DIR/06b_haplotypecaller.sh)

'''
##########################
# Part 4 of the pipeline #
##########################
'''

##### Set up scaffold input files to fit with Compute Canada max jobs
# How many scaffolds are in the genome...
SCAFF_N=$(cat $SPECIES_DIR/03_genome/*fai | wc -l)
SPLIT_N=200

# Split these over $SPLIT_N jobs...
cut -f1 $SPECIES_DIR/03_genome/*fai | shuf > 02_info_files/all_scafs.txt
if [[ $SCAFF_N -gt $SPLIT_N ]]
then
 split -l$((`wc -l < 02_info_files/all_scafs.txt`/${SPLIT_N})) 02_info_files/all_scafs.txt 02_info_files/all_scafs.split. -da 4 --additional-suffix=".pos"
else
 split -l$((`wc -l < 02_info_files/all_scafs.txt`/${SCAFF_N})) 02_info_files/all_scafs.txt 02_info_files/all_scafs.split. -da 4 --additional-suffix=".pos"
fi

# Set SNP-calling array over these scaffold clusters...
SCAFF_ARRAY=$(($(ls 02_info_files/all_scafs*pos | wc -l)-1))

##########################
##### Make some metadata
#### GVCF Sample List (after job 6 finishes)...
cut -f1 02_info_files/datatable.txt | awk -v OFS="\t" '{
  gvcf="07b_gvcfs/" $1 ".g.vcf"
  print $1,gvcf
}'> 02_info_files/gvcfs_map

#### Ploidy file...
# Ploidy information is built from gvcf list
cut -f1,2 02_info_files/datatable.txt > ploidymap.txt

##########################
# Call SNPs
export DATASET=$DATASET
job07=$(sbatch -p ${LR_PARTITION} -q ${LR_QOS} \
   --array=0-${SCAFF_ARRAY} \
   --dependency=afterok:${job06} \
   --mail-type=ALL \
   --mail-user=$EMAIL \
   --export DATASET \
   --parsable \
   $PIPE_DIR/07b_genomicsdb_genotypegvcfs.sh)

# Concatenate VCFs
export DATASET=$DATASET
job08=$(sbatch -p ${LR_PARTITION} -q ${LR_QOS} \
   --dependency=afterany:$job07 \
   --mail-type=ALL \
   --mail-user=$EMAIL \
   --export DATASET \
   --parsable \
   $PIPE_DIR/08b_concat_VCFs.sh)

# FILTER
export DATASET=$DATASET
sbatch -p ${LR_PARTITION} -q ${LR_QOS} \
   --mail-type=ALL \
   --dependency=afterok:$job08 \
   --mail-user=$EMAIL \
   --export DATASET \
   $PIPE_DIR/09b_VCF_filtering.sh

##########################
