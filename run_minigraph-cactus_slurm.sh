#!/bin/bash
#SBATCH -J mg-cactus-submit
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 1
#SBATCH --mem=2G
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
cactus-pangenome "$scratch" "$seqfile" --outDir ${outdir} --outName ${outpref} \
  --reference interiorprim --refContigs $(for i in $(seq 1 13) ; do printf "chr$i" ; done) --otherContig chrOther \
  --batchSystem slurm  --slurmPartition gpu --slurmGPUPartition gpu --slurmArgs "$sarg" \
  --batchLogsDir ${outdir}/log --workDir ${scratch} --maxMemory 500G --consCores 64 --doubleMem true \
  --vcf --viz --gfa --gbz --odgi --chrom-og
