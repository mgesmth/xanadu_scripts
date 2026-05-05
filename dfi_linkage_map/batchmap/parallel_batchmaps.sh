#!/bin/bash

LG_num=${SLURM_ARRAY_TASK_ID}
core=/core/projects/EBP/smith
dir=${core}/linkage_snp_calling/11_batchmap
batchmap=${core}/bin/batchmap.sif
ncore=$SLURM_CPUS_PER_TASK

singlarity exec ${batchmap} Rscript \
../01_scripts/create_batchmap_perLG.R \
${dir} ${LG_num} ${ncore}
