#!/bin/bash

#array=($(cat linkage_groups.txt))
#LG_num=${array[$SLURM_ARRAY_TASK_ID]}
LG=$1
core=/core/projects/EBP/smith
dir=${core}/linkage_snp_calling_final/11_batchmap
batchmap=${core}/bin/batchmap.sif
ncore=$SLURM_CPUS_PER_TASK
scripts=${dir}/scripts

cp scripts/create_batchmap_perLG.R .
singlarity exec ${batchmap} Rscript create_batchmap_perLG.R \
${dir} ${LG_num} ${ncore}
