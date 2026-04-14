#!/bin/bash

home=/home/FCAM/msmith
workdir=${home}/repeats_round2
log=${workdir}/log
repscripts=${home}/scripts/repeats
asm=/core/projects/EBP/smith/3ddna_again/interior_primary_final.FINAL.fasta

#prep workspace (if not already)
cd ${workdir}
if [[ ! -d "first_20" || ! -d "above_1Mb" || ! -d "below_1Mb" || ! -d "log" ]] ; then
  echo ">> One of required subdirectories not detected. Setting up workspace..."
  if [[ ! -d "first_20" ]] ; then
    mkdir first_20
  fi

  if [[ ! -d "above_1Mb" ]] ; then
    mkdir above_1Mb
  fi

  if [[ ! -d "below_1Mb" ]] ; then
    mkdir below_1Mb
  fi
fi

if [[ ! -d "concatenated_results" ]] ; then
  echo ">> One of required subdirectories not detected. Setting up workspace..."
  mkdir concatenated_results
  mkdir concatenated_results/fa.out_files
  mkdir concatenated_results/fa.tbl_files
elif [[ -d "concatenated_results" && ! -d "concatenated_results/fa.out_files" || ! -d "concatenated_results/fa.tbl_files" ]] ; then
  echo ">> One of required subdirectories not detected. Setting up workspace..."
  if [[ ! -d "concatenated_results/fa.out_files" ]] ; then
    mkdir concatenated_results/fa.out_files
  fi
  if [[ ! -d "concatenated_results/fa.tbl_files" ]] ; then
    mkdir concatenated_results/fa.tbl_files
  fi
else
  echo ">> Expected subdirectories are all present."
fi

#split assembly to work in parallel
split=$(sbatch -D ${workdir} -o ${log}/%x.%j.out -e ${log}/%x.%j.err \
--parsable ${repscripts}/split_asm_for_repeatMasker.sh ${asm})

#run repeatMasker on three scaffold categories
sbatch --dependency=afterok:${split} -D ${workdir} \
-o ${log}/%x.%A.%a.out -e ${log}/%x.%A.%a.err \
--parsable ${repscripts}/repeatMasker_20.sh > first20_jobnum.txt

#wait until split job is done
first20=$(tr -d '\n' < first20_jobnum.txt)
above_array_len=$(($(cat ${workdir}/above_1Mb/above1Mb.txt | wc -l)-1))

above1Mb=$(sbatch --dependency=afterok:${split} -D ${workdir} \
--array=0-${above_array_len} \
-o ${log}/%x.%A.%a.out -e ${log}/%x.%A.%a.err \
--parsable ${repscripts}/repeatMasker_above1Mb.sh)

below_array_len=$(($(cat ${workdir}/below_1Mb/below1Mb.txt | wc -l)-1))

below1Mb=$(sbatch --dependency=afterok:${split} -D ${workdir} \
--array=0-${below_array_len} \
-o ${log}/%x.%A.%a.out -e ${log}/%x.%A.%a.err \
--parsable ${repscripts}/repeatMasker_below1Mb.sh)

#concatenate results
sbatch \
--dependency=afterok:${first_20},afterok:${above1Mb},afterok:${below1Mb} \
-o ${log}/%x.%j.out -e ${log}/%x.%j.err ${repscripts}/concatenating_masked_sequences.sh

sbatch -o ${log}/%x.%j.out -e ${log}/%x.%j.err \
${repscripts}/concatenating_masked_sequences.sh ${workdir} ${repscripts}
