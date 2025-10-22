#!/bin/bash

home=/home/FCAM/msmith
core=/core/projects/EBP/smith
mg_dir=${core}/manual_curation_files/minigraph
pgscripts=${home}/scripts/pangenome/repeat_analysis

cd ${mg_dir}/repeat_masker_dir

#Create SV sequence files by scaffold
${pgscripts}/extract_insertedalleles.sh
array_num=$(echo $(($(cat fasta_files.iterator | wc -l)-1)))

#Run analysis pipeline as an array per scaffold
sbatch --array=[0-${array_num}] ${pgscripts}/runRM_and_filtermatches.sh | cut -d ' ' -f4 > rmjid.tmp
rmjid=$(tr -d '\n' < rmjid.tmp)

#Merge surviving matches 
