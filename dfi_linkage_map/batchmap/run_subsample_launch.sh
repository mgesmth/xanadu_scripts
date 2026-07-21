#!/bin/bash
#SBATCH -J subsample_launch
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 1
#SBATCH --mem=1G
#SBATCH -D /core/projects/EBP/smith/linkage_actually/11_batchmap_10kb
#SBATCH -o log/%x.%j.out
#SBATCH -e log/%x.%j.err

echo `hostname`
set -e

LG=$1
outdir="${LG}_subsamples"
if [[ ! -d "$outdir" ]] ; then
	mkdir $outdir
fi
subsamp_script=batchmap_createsubsampled_maps.R
if [[ ! -f "$subsamp_script" ]] ; then
	cp scripts/${subsamp_script} .
fi


for i in $(seq 1 5); do
	sbatch scripts/run_subsample_iteration.sh \
	${outdir} $subsamp_script $LG $i
	echo "iteration $i submitted"
done

