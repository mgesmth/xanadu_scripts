#!/bin/bash
#SBATCH -J build_batchmap
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 20
#SBATCH --array=[0-12]
#SBATCH -D /core/projects/EBP/smith/linkage_actually/11_batchmap_gq99_alldepth
#SBATCH --mem=64G
#SBATCH --mail-user=meg8130@student.ubc.ca
#SBATCH --mail-type=ALL
#SBATCH -o /core/projects/EBP/smith/linkage_actually/11_batchmap_gq99_alldepth/log/%x.%A.%a.out
#SBATCH -e /core/projects/EBP/smith/linkage_actually/11_batchmap_gq99_alldepth/log/%x.%A.%a.err

set -e
echo `hostname`

iteration=$1

array=($(cat linkage_groups.txt))
LG_num=${array[$SLURM_ARRAY_TASK_ID]}
core=/core/projects/EBP/smith
dir=${core}/linkage_actually/11_batchmap_gq99_alldepth
batchmap=${core}/bin/batchmap.sif
ncore=$SLURM_CPUS_PER_TASK
scripts=${dir}/scripts

echo "[M]: Creating map for ${LG_num}..."

cp scripts/batchmap_createmap_perLG.R .
singularity exec ${batchmap} Rscript batchmap_createmap_perLG.R \
${LG_num} ${ncore} $iteration
