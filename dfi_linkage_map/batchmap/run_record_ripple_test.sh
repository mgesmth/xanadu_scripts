#!/bin/bash
#SBATCH -J test_record_ripple
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 20
#SBATCH --mem=84G
#SBATCH -D /core/projects/EBP/smith/linkage_last/11_batchmap_forreal
#SBATCH -o /core/projects/EBP/smith/linkage_last/11_batchmap_forreal/log/%x.%j.out
#SBATCH -e /core/projects/EBP/smith/linkage_last/11_batchmap_forreal/log/%x.%j.err

echo `hostname`

module load singularity/3.9.2

dir=/core/projects/EBP/smith/linkage_last/11_batchmap_forreal
LG=$1
scripts=${dir}/scripts
batchmap=/core/projects/EBP/smith/bin/batchmap.sif

cp ${scripts}/test_record_ripple_capabilities.R .
singularity exec ${batchmap} Rscript test_record_ripple_capabilities.R $LG