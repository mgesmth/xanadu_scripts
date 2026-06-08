#!/bin/bash
#SBATCH -J build_recmap_test
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 24
#SBATCH -D /core/projects/EBP/smith/linkage_snp_calling_final/11_batchmap_physbin100kb_prebin
#SBATCH --mem=128G
#SBATCH --mail-user=meg8130@student.ubc.ca
#SBATCH --mail-type=ALL
#SBATCH -o /core/projects/EBP/smith/linkage_snp_calling_final/11_batchmap_physbin100kb_prebin/log/%x.%j.out
#SBATCH -e /core/projects/EBP/smith/linkage_snp_calling_final/11_batchmap_physbin100kb_prebin/log/%x.%j.err

set -e
echo `hostname`

core=/core/projects/EBP/smith
dir=${core}/linkage_snp_calling_final/11_batchmap_physbin100kb_prebin
batchmap=${core}/bin/batchmap.sif
ncore=$SLURM_CPUS_PER_TASK
scripts=${dir}/scripts

cp scripts/build_record_map.R .
singularity exec ${batchmap} build_record_map.R
