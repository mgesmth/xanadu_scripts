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
module load blast/2.15.0

home=/home/FCAM/msmith
core=/core/projects/EBP/smith
scratch=/scratch/msmith
mg_dir=${core}/minigraph
bed_filt=${mg_dir}/final_finalpangenome_filtered2.bed
workdir=${mg_dir}/gene_dup_dir/interior
db=${workdir}/geneseqdb/interior_geneseqs_justint
pgscripts=${home}/scripts/pangenome/gene_dup_analysis
threshold=$1

cd ${workdir}/byscaffold_svs_${threshold}

if [[ ! -d extra_and_error/ ]] ; then
  mkdir extra_and_error
fi 

fastas=($(cat fasta_files.iterator))
fasta=${fastas[$SLURM_ARRAY_TASK_ID]}
scaffold=${fasta/_svs.fasta/}

echo ""
echo "[M]: Welcome to Slurm Task ${SLURM_ARRAY_TASK_ID}."
echo "[M]: We are analyzing SVs found on ${scaffold} for genes."
echo "[M]: Running RepeatMasker..."
echo ""

#Run
blastn -db ${db} -query ${fasta} -out ${fasta}.out -outfmt='6 score evalue qseqid qstart qend qlen sstrand sseqid sstart send slen'

echo ""
echo "[M]: Done RepeatMasker. Beginning filtering of matches against a threshold of ${threshold}..."

python ${pgscripts}/filter_output.py \
  ${fasta}.out ${scaffold}_filtered.${threshold}_svs.fasta.out \
  "$threshold" \
  extra_and_error/${scaffold}_below.${threshold}_svs.fasta.out

echo ""
echo "[M]: Done filtering. Bye!"
