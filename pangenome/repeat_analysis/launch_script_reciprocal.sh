#!/bin/bash
#SBATCH -J repeat_analysis_launch
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 10
#SBATCH --mem=24G
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

set -e

home=/home/FCAM/msmith
core=/core/projects/EBP/smith
mg_dir=${core}/minigraph
pgscripts=${home}/scripts/pangenome/repeat_analysis
#if you want to change the stringency threshold, change it here:
threshold=0.85
log=${mg_dir}/repeat_masker_dir/log

date
echo "[M]: Host Name: `hostname`"

#create a working directory
if [[ ! -d ${mg_dir}/repeat_masker_dir ]] ; then
  mkdir ${mg_dir}/repeat_masker_dir
  if [[ ! -d ${log} ]] ; then
    mkdir ${log}
  fi
fi

workdir=${mg_dir}/repeat_masker_dir
byscaffdir=${workdir}/byscaffold_svs_${threshold}
cd ${byscaffdir}

ls -1 *.out | grep -v "filtered" > RMout_unfiltered.iterator

array_num=$(echo $(($(cat RMout_unfiltered.iterator | wc -l)-1)))

#Run analysis pipeline as an array per scaffold (at an 0.85 threshold)
cd ${log}
sbatch --array=[0-${array_num}] ${pgscripts}/filtermatches_reciprocal.sh ${threshold} | cut -d ' ' -f4 > rmjid.tmp
rmjid=$(tr -d '\n' < rmjid.tmp)

#Merge surviving matches
sbatch -d afterok:${rmjid} ${pgscripts}/merge_surviving_alignments_reciprocal.sh ${threshold}

rm rmjid.tmp
