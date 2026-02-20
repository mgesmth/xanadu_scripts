#!/bin/bash

cd ~/repeats_mancur/concatenated_results

awk -F "\t" -v OFS="\t" 'NR==1 { print ; next } {
  if ($16 == "F") {
    print
  } else {
    next
  }
}' repeatMasker_merged.out > repeatMasker_merged_bestmatches.out

#check to see if the orientation of query alignments is reversed
cut -f5,6,7,11 repeatMasker_merged_bestmatches.out | \
awk -F "\t" 'NR>1 {
  if ($2 > $3) {
    print $0
    exit
  } else {
    next
  }
}'

#nothing. Isolate chr records and just coordinates & repeat families

awk -F "\t" -v OFS="\t" 'NR==1 {next} {
  split($5,m,"_")
  chrnum=m[3]*1
  if (chrnum <= 13) {
    print $5,$6,$7,$11
  } else {
    next
  }
}' repeatMasker_merged_bestmatches.out > repeat_coordinates.tsv

#move over to R to test relationship to SV density!
