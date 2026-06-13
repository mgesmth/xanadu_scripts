#!/bin/bash
#SBATCH -J build_batchmap
#SBATCH -p himem
#SBATCH -q himem
#SBATCH -c 24
#SBATCH -D /core/projects/EBP/smith/linkage_last/11_batchmap_forreal4
#SBATCH --mem=500G
#SBATCH --mail-user=meg8130@student.ubc.ca
#SBATCH --mail-type=ALL
#SBATCH -o /core/projects/EBP/smith/linkage_last/11_batchmap_forreal4/log/%x.%j.out
#SBATCH -e /core/projects/EBP/smith/linkage_last/11_batchmap_forreal4/log/%x.%j.err

set -e
echo `hostname`

#array=($(cat linkage_groups.txt))
#LG_num=${array[$SLURM_ARRAY_TASK_ID]}
LG_num=$1
ripple_tries=$2
ws=$3
method=$4
core=/core/projects/EBP/smith
dir=${core}/linkage_last/11_batchmap_forreal4
batchmap=${core}/bin/batchmap.sif
ncore=$SLURM_CPUS_PER_TASK
scripts=${dir}/scripts

cp scripts/batchmap_createmap_perLG.R .
singularity exec ${batchmap} Rscript batchmap_createmap_perLG.R \
${dir} ${LG_num} ${ncore} ${ripple_tries} ${ws} ${method}
