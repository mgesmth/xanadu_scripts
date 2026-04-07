#!/bin/bash

module load seqkit/

asm=interior_primary_final.fa
maxlen=1000000000

#first 7 scaffolds are above 1Gb. These will be split.
awk '{ if ($0 == ">scaffold_8_primary") {
  exit
} else {
  print
}}' ${asm} > to_be_split.fa

seqkit sliding -g -s ${maxlen} -W ${maxlen} to_be_split.fa | \
  awk '{ if ($0 ~ /^>/) {
    if ($1 ~ "sliding:1-") {
      #if the coordinate starts with 1, its the first fragment
      frag=1
    } else if ($1 ~ "sliding:2") {
      #if the coordinate starts with 2, its the third frag
      frag=3
    } else {
      frag=2
    }
    split($1,m,"_")
    $1=m[1] "_" m[2] "_" m[3] "_" frag
    print
  } else {
    print
  }}' > split.fa && rm to_be_split.fa

linenum=$(($(grep -n "scaffold_8_primary" interior_primary_final.fa | head -n1 | cut -f1 -d ":")-1))
totlen=$(wc -l interior_primary_final.fa | cut -f1 -d " ")
tail=$(( ${totlen}-${linenum} ))

tail -n ${tail} interior_primary_final.fa >> split.fa
mv split.fa interior_primary_final_split.fa
