#!/bin/bash
#SBATCH -J sv_repeat_analysis
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 4
#SBATCH --mem=8G
#SBATCH -o %x.%A.%a.out
#SBATCH -e %x.%A.%a.err

set -e
date
echo "[M]: Host Name: `hostname`"
module load python/3.8.1

home=/home/FCAM/msmith
core=/core/projects/EBP/smith
scratch=/scratch/msmith
mg_dir=${core}/minigraph
workdir=${mg_dir}/repeat_masker_dir
pgscripts=${home}/scripts/pangenome/repeat_analysis
threshold=$1

cd ${workdir}/byscaffold_svs_${threshold}

out_files=($(cat RMout_unfiltered.iterator))
out=${out_files[$SLURM_ARRAY_TASK_ID]}
scaffold=${out/_svs.fasta.out/}

echo ""
echo "[M]: Welcome to Slurm Task ${SLURM_ARRAY_TASK_ID}."
echo "[M]: We are analyzing SVs found on ${scaffold} for TE insertions."
echo "[M]: Running filter on RepeatMasker output..."
echo ""

python ${pgscripts}/filter_RMoutput_reciprocal.py \
  ${out} ${scaffold}_filtered.${threshold}_reciprocal.fasta.out \
  "$threshold" \
  extra_and_error/${scaffold}_below.${threshold}_reciprocal.fasta.out

echo ""
echo "[M]: Done filtering. Bye!"
