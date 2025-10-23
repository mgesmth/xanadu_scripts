#!/bin/bash
#SBATCH -J repeat_analysis_launch
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 4
#SBATCH --mem=10G
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

set -e

home=/home/FCAM/msmith
core=/core/projects/EBP/smith
mg_dir=${home}/svs/minigraph_out/finalpangenome
pgscripts=${home}/scripts/pangenome/repeat_analysis_test
#if you want to change the stringency threshold, change it here:
threshold=0.85

date
echo "[M]: Host Name: `hostname`"

#create a working directory
if [[ ! -d ${mg_dir}/repeat_masker_dir ]] ; then
  mkdir ${mg_dir}/repeat_masker_dir
fi

cd ${mg_dir}/repeat_masker_dir

#Create SV sequence files by scaffold
chmod +x ${pgscripts}/extract_insertedalleles.sh
${pgscripts}/extract_insertedalleles.sh ${threshold}
array_num=$(echo $(($(cat byscaffold_svs_${threshold}/fasta_files.iterator | wc -l)-1)))

#Run analysis pipeline as an array per scaffold (at an 0.85 threshold)
sbatch --array=[0-${array_num}] ${pgscripts}/runRM_and_filtermatches.sh ${threshold} | cut -d ' ' -f4 > rmjid.tmp
rmjid=$(tr -d '\n' < rmjid.tmp)

#Merge surviving matches
sbatch -d afterok:${rmjid} ${pgscripts}/merge_surviving_alignments.sh ${threshold}

rm rmjid.tmp byscaffold_svs/fasta_files.iterator
