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

home=/home/FCAM/msmith
core=/core/projects/EBP/smith
scratch=/scratch/msmith
mg_dir=${home}/svs/minigraph_out/finalpangenome
bed_filt=${mg_dir}/finalpangenome_filtered2.bed
workdir=${mg_dir}/repeat_masker_dir
db=${home}/repeats/primary_db
tetools=${core}/bin/dfam-tetools-latest.sif
pgscripts=${home}/scripts/pangenome/repeat_analysis_test
threshold=$1

cd ${workdir}/byscaffold_svs_${threshold}

fastas=($(cat byscaffold_svs/fasta_files.iterator))
fasta=${fastas[$SLURM_ARRAY_TASK_ID]}
scaffold=${fasta/_svs.fasta/}

echo ""
echo "[M]: Welcome to Slurm Task ${SLURM_ARRAY_TASK_ID}."
echo "[M]: We are analyzing SVs found on ${scaffold} for TE insertions."
echo "[M]: Running RepeatMasker..."
echo ""

#Run
singularity exec $tetools \
RepeatMasker -frag 60000000 -pa 6 -q -dir ${repdir} -lib "${db}/primary-families.fa" "${fasta}"
#remove masked sequence - don't need it, just the reports
rm ${fasta}.cat.gz ${fasta}.masked.gz
#move tbl to extra_and_error - leave just the out file
mv ${fasta}.tbl extra_and_error

echo ""
echo "[M]: Done RepeatMasker. Beginning filtering of matches against a threshold of ${threshold}..."

python ${pgscripts}/filter_RMoutput.py \
  ${fasta}.out ${scaffold}_filtered${threshold}_svs.fasta \
  "$threshold" \
  extra_and_error/${scaffold}_below${threshold}.out

echo ""
echo "[M]: Done filtering. Bye!"
