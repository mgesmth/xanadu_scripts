#!/bin/bash
#SBATCH -J merge_surviving_alignments
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 12
#SBATCH --mem=56G
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

set -e

home=/home/FCAM/msmith
core=/core/projects/EBP/smith
scratch=/scratch/msmith
mg_dir=${core}/minigraph
workdir=${mg_dir}/repeat_masker_dir
threshold=$1
outfile=${workdir}/final_finalpangenome_TEs_${threshold}.out

cd ${workdir}/byscaffold_svs_${threshold}
ls -1 *filtered*.out > fasta_files_filt.iterator
touch ../$outfile

for file in $(cat fasta_files_filt.iterator) ; do
  scaffold=${file/_svs.fasta/}
  cat ${scaffold}_filtered.${threshold}_svs.fasta.out >> $outfile
done

rm *.iterator
