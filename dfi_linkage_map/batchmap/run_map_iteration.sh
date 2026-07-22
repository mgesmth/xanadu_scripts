#!/bin/bash
#SBATCH -J map_iter
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 10
#SBATCH --mem=48G
#SBATCH -o log/%x.%A.%a.out
#SBATCH -e log/%x.%A.%a.err

echo `hostname`
set -e
module load singularity/3.9.2

outdir=$1
subsample_script=$2
LG=$3
iter=$(echo $((${SLURM_ARRAY_TASK_ID}+1)))
batchmap=/core/projects/EBP/smith/bin/batchmap.sif 
cores=$SLURM_CPUS_PER_TASK

singularity exec $batchmap Rscript $subsample_script \
$cores $outdir $LG $iter 
