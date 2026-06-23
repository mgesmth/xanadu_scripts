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

outdir=$1
subsample_script=$2
LG=$3
iter=$4
batchmap=/core/projects/EBP/smith/bin/batchmap.sif 
cores=$SLURM_CPUS_PER_TASK

run=$(basename {subsample_script})
if [[ ! -f "$run" ]] ; then
	cp $subsample_script .
fi
singularity exec $batchmap Rscript $run \
$cores $outdir $LG $iter 
