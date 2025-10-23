#!/bin/bash
#SBATCH -J merge_surviving_alignments
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 4
#SBATCH --mem=12G
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

set -e

home=/home/FCAM/msmith
core=/core/projects/EBP/smith
scratch=/scratch/msmith
mg_dir=${home}/svs/minigraph_out/finalpangenome
workdir=${mg_dir}/repeat_masker_dir
threshold=$1
outfile=finalpangenome_TEs_${threshold}_test.out

cd ${workdir}/byscaffold_svs_${threshold}
touch ../$outfile

for file in $(cat fasta_files.iterator) ; do
  scaffold=${file/_svs.fasta/}
  cat byscaffold_svs_${threshold}/${scaffold}_filtered${threshold}_svs.fasta >> ../$outfile
done

rm fasta_files.iterator
