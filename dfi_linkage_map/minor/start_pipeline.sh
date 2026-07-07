#!/bin/bash
#!/bin/bash
# Submit scripts from the $SPECIES_DIR directory

core=/core/projects/EBP/smith

# Variables
# Name of general working directory
MAIN=${core}
# Name of directory where snp calling is happening
DATASET="linkage_snp_calling_minorscaffolds"
SPECIES_DIR=$MAIN/$DATASET
cd $SPECIES_DIR

# Point to directory where scripts are
PIPE_DIR="01_scripts"

# Set metadata
DATATABLE=$SPECIES_DIR/02_info_files/datatable.txt

# Set Email for slurm reports
EMAIL="meg8130@student.ubc.ca"

LR_PARTITION="general"
LR_QOS="general"

job00=$(sbatch -p ${LR_PARTITION} -q ${LR_QOS} \
-D $SPECIES_DIR \
--mail-type=ALL \
--mail-user=$EMAIL \
--parsable \
$PIPE_DIR/00.prep_genome.sh)

'''
##########################
# Part 1 of the pipeline #
##########################
'''

arrlen=$(($(cat 02_info_files/datatable.txt | wc -l)-1))

# Trim
job01=$(sbatch -p ${LR_PARTITION} -q ${LR_QOS} \
--dependency=afterok:${job00} \
--array=[0-${arrlen}]%20 \
   -D $SPECIES_DIR \
   --mail-type=ALL \
   --mail-user=$EMAIL \
   --parsable \
   $PIPE_DIR/01.fastp.sh)

# Align
job02=$(sbatch -p ${LR_PARTITION} -q ${LR_QOS} \
--array=[0-${arrlen}]%20\
   --dependency=afterok:${job01} \
   -D $SPECIES_DIR \
   --mail-type=ALL \
   --mail-user=$EMAIL \
   --parsable \
   $PIPE_DIR/02.bwa_alignments.sh)

# Collect sample data metrics
job03=$(sbatch -p ${LR_PARTITION} -q ${LR_QOS} \
--array=[0-${arrlen}]%20 \
   --dependency=afterok:$job02 \
   -D $SPECIES_DIR \
   --mail-type=ALL \
   --mail-user=$EMAIL \
   --parsable \
   $PIPE_DIR/03.collect_metrics.sh)

# Remove duplicates
job04=$(sbatch -p ${LR_PARTITION} -q ${LR_QOS} \
--array=[0-${arrlen}]%20 \
   --dependency=afterok:$job03 \
   -D $SPECIES_DIR \
   --mail-type=ALL \
   --mail-user=$EMAIL \
   --parsable \
   $PIPE_DIR/04.remove_duplicates.sh)

# Change bam files RG
job05=$(sbatch -p ${LR_PARTITION} -q ${LR_QOS} \
--array=[0-${arrlen}]%20 \
   --dependency=afterok:$job04 \
   -D $SPECIES_DIR \
   --mail-type=ALL \
   --mail-user=$EMAIL \
   --parsable \
   $PIPE_DIR/05.change_RG.sh)

# Call variants
job06=$(sbatch -p ${LR_PARTITION} -q ${LR_QOS} \
--array=[0-${arrlen}]%20 \
--dependency=afterok:${job05} \
   -D $SPECIES_DIR \
   --mail-type=ALL \
   --mail-user=$EMAIL \
   --parsable \
   $PIPE_DIR/06.haplotypecaller.sh)

'''
##########################
# Part 2 of the pipeline #
##########################
'''

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
cut -f1,2 02_info_files/datatable.txt > 02_info_files/ploidymap.txt

cd 02_info_files
ls -1 *.pos > pos.txt
cd ..

##########################
# Call SNPs

ls -1 07_gvcfs/*.vcf | awk '{print "-V",$1}' > argument_file.tmp
job07=$(sbatch -p ${LR_PARTITION} -q ${LR_QOS} \
   --array=[0-${SCAFF_ARRAY}]%20 \
   --dependency=afterok:${job06} \
   --mail-type=ALL \
   --mail-user=$EMAIL \
   --parsable \
   $PIPE_DIR/07.combinegvcfs_genotypegvcfs.sh $DATASET)

# Concatenate VCFs
job08=$(sbatch -p ${LR_PARTITION} -q ${LR_QOS} \
   --mail-type=ALL \
   --dependency=afterok:$job07 \
   --mail-user=$EMAIL \
   --parsable \
   $PIPE_DIR/08.concat_VCFs.sh $DATASET)

# FILTER
job09=$(sbatch -p ${LR_PARTITION} -q ${LR_QOS} \
--dependency=afterok:${job08} \
   --mail-type=ALL \
   --mail-user=$EMAIL \
   --parsable \
   $PIPE_DIR/09b.filt_VCFs.sh $DATASET)

#build batchmap file
sbatch -p ${LR_PARTITION} -q ${LR_QOS} \
--dependency=afterok:${job09} \
  --mail-type=ALL \
  --mail-user=$EMAIL \
  $PIPE_DIR/10.batchmap_file.sh $DATASET
##########################
