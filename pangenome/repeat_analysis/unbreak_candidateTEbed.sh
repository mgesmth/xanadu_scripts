#!/bin/bash

#isolate split scaffolds in FAI
head -n12 interior_primary_final_mancur_1Mb.fa.fai > split.fa.fai

awk -F "\t" -v OFS="\t" 'NR==FNR {
  if ($1 ~ /_1$/) {
    arr[$1]=$2
  }
  next
}{
  if ($1 ~ /_1$/) {
    split($1,m,"_")
    $1="HiC_scaffold_" m[3]
    print
  } else if ($1 ~ /_2$/) {
    split($1,m,"_")
    frag1="HiC_scaffold_" m[3] "_1"
    add=arr[frag1]+200
    $2+=add
    $3+=add
    $1="HiC_scaffold_" m[3]
    print
  } else {
    print
  }
}' split.fa.fai candidateTEs.bed > candidateTEs_unbroken.bed
