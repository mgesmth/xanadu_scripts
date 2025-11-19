#!/bin/bash
#SBATCH -J mg-cactus-submit
#SBATCH -p gpu
#SBATCH -q general
#SBATCH -c 64
#SBATCH --mem=500G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=meg8130@student.ubc.ca
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

echo "[M]: Host Name: `hostname`"

module load singularity/3.10.0
module load squashfs/4.3

home=/home/FCAM/msmith
core=/core/projects/EBP/smith
scratch=/scratch/msmith
outpref=dougfir_mgcactus
outdir=/core/projects/EBP/smith/mg_cactus
seqfile=${core}/mg_cactus/mg-cactus_fas.txt
sarg="-q general"

singularity exec /isg/shared/mantis/apps/cactus/2.9.8/cactus_v2.9.8-gpu.sif \
cactus-pangenome "${scratch}/mg_tmp" "$seqfile" --outDir ${outdir} --outName ${outpref} \
  --reference interiorprim --refContigs $(for i in $(seq 1 13) ; do printf "chr$i" ; done) --otherContig scaffoldOther \
  --consMemory 500G --indexMemory 300G --mgMemory 500G --maxDisk 400G \
  --vcf --viz --gfa --gbz --odgi --chrom-og
