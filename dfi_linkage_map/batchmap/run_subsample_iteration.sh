#!/bin/bash
#SBATCH -J subsampled_map_iter
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 10
#SBATCH --mem=48G
#SBATCH -o log/%x.%j.out
#SBATCH -e log/%x.%j.err

echo `hostname`
set -e
module load singularity/3.9.2

subsample_script=$1
LG=$2
iter=$3
batchmap=/core/projects/EBP/smith/bin/batchmap.sif 
cores=$SLURM_CPUS_PER_TASK
outdir=$SLURM_SUBMIT_DIR

run=$(basename {subsample_script})
if [[ ! -f "$run" ]] ; then
	cp $subsample_script .
fi
singularity exec $batchmap Rscript $run $outdir $cores $LG $iter 
