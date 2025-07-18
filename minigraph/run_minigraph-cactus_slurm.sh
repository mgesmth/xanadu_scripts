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

home=/home/FCAM/msmith
core=/core/projects/EBP/smith
scratch=/scratch/msmith
outpref=dougfir_mgcactus
outdir=/core/projects/EBP/smith/mg_cactus
seqfile=${core}/mg_cactus/mg-cactus_fas.txt
sarg="-q himem"

source ${core}/bin/cactus/cactus_env/bin/activate

cactus-pangenome "${scratch}/mg_tmp" "$seqfile" --outDir ${outdir} --outName ${outpref} \
  --reference interiorprim --refContigs $(for i in $(seq 1 13) ; do printf "chr$i" ; done) --otherContig chrOther \
  --batchSystem slurm  --slurmPartition himem --slurmGPUPartition gpu --slurmArgs "$sarg" \
  --batchLogsDir ${outdir}/log --workDir ${scratch} --maxMemory 750G --consCores 64 \
  --indexCores 36 --doubleMem true --mgCores 36 --mapCores 8 \
  --vcf --viz --gfa --gbz --odgi --chrom-og --binariesMode singularity
