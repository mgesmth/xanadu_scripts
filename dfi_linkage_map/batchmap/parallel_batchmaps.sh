#!/bin/bash
#SBATCH -J build_batchmap_test
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 24
#SBATCH -D /core/projects/EBP/smith/linkage_snp_calling_final/11_batchmap
#SBATCH --mem=128G
#SBATCH --mail-user=meg8130@student.ubc.ca
#SBATCH --mail-type=ALL
#SBATCH -o /core/projects/EBP/smith/linkage_snp_calling_final/11_batchmap/log/%x.%j.out
#SBATCH -e /core/projects/EBP/smith/linkage_snp_calling_final/11_batchmap/log/%x.%j.err

set -e
echo `hostname`

#array=($(cat linkage_groups.txt))
#LG_num=${array[$SLURM_ARRAY_TASK_ID]}
LG="LG_50"
core=/core/projects/EBP/smith
dir=${core}/linkage_snp_calling_final/11_batchmap
batchmap=${core}/bin/batchmap.sif
ncore=$SLURM_CPUS_PER_TASK
scripts=${dir}/scripts

cp scripts/create_batchmap_perLG.R .
singularity exec ${batchmap} Rscript create_batchmap_perLG.R \
${dir} ${LG_num} ${ncore}
