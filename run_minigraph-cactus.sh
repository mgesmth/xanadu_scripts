#!/bin/bash
#SBATCH -J mg-cactus-submit
#SBATCH -p gpu
#SBATCH -q general
#SBATCH -c 1
#SBATCH --mem=2G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=meg8130@student.ubc.ca
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

echo "[M]: Host Name: `hostname`"

module load cactus/2.9.8

home=/home/FCAM/msmith
core=/core/projects/EBP/smith
scratch=/scratch/msmith
outpref=dougfir_mgcactus
outdir=/core/projects/EBP/smith/mg_cactus
seqfile=${scratch}/mg-cactus_fas.txt

cactus-pangenome ${scratch} ${seqfile} --outDir ${outdir} --outName ${outpref} \
  --reference interior.1 --refContigs $(for i in $(seq 1 13) ; do printf "chr$i" ; done) --otherContig chrOther \
  --batchSystem slurm  --slurmPartition gpu --slurmGPUPartition gpu --slurmArgs --qos=general \
  --batchLogsDir ${outdir}/log --workDir ${scratch} --maxMemory 500G --consCores 64 --doubleMem true \
  --vcf --viz --gfa --gbz --vg --odgi --chrom-og
  
  
