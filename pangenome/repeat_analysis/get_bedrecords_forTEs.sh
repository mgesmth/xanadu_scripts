#!/bin/bash

cd /core/projects/EBP/smith/minigraph/repeat_masker_dir
awk '$12 != "Unknown" { print }' final_finalpangenome_TEs_0.85_reciprocal.out > final_finalpangenome_TEs_0.85_reciprocal_nounknown.out

mkdir out_split
cd out_split
cut -f5 final_finalpangenome_TEs_0.85_reciprocal_nounknown.out | uniq > uniq_scaffolds.txt

#split tes into one file per scaffold for easy processing
touch ../candidateTEs.bed
cat uniq_scaffolds.txt | while read -r scaffold ; do
  grep -w "$scaffold" ../final_finalpangenome_TEs_0.85_reciprocal_nounknown.out | \
  sort -g -k6 > candidateTEs_${scaffold}.out

  grep -w "$scaffold" ../../final_finalpangenome_filtered2.bed > ${scaffold}_allsvs.bed
  awk -v OFS="\t" 'FNR==NR{
    #build an array with indices matching the line numbers I want to extract
    sv_numbers[$6]=1
    next
  } (FNR in sv_numbers) {
    print
  }' candidateTEs_${scaffold}.out ${scaffold}_allsvs.bed >> ../candidateTEs.bed
  rm candidateTEs_${scaffold}.out ${scaffold}_allsvs.bed
done

cd ..
rm -r out_split/
