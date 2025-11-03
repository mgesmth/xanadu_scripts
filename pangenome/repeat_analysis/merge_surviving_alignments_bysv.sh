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
outfile=${workdir}/final_finalpangenome_TEs_${threshold}_bysv.out

cd ${workdir}/byscaffold_svs_${threshold}
ls -1 *filtered*.out | grep "bysv" | sort -t "_" -g -k 3 > fasta_files_filt_bysv.iterator
touch tmp

for file in $(cat fasta_files_filt_bysv.iterator) ; do
  cat ${file} >> tmp
done

#split scaffold and sv name in outfile
awk -v OFS="\t" '{
  split($5,m,"sv")
  print $1,$2,$3,$4,substr(m[1],1,length(m[1])-1),m[2],$6,$7,$8,$9,$10,$11,$12,$13,$14}' tmp > ${outfile}

rm tmp *.iterator
