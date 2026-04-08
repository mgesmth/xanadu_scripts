#!/bin/bash

module load seqkit samtools

asm=interior_primary_final.fa
maxlen=500000000

asm_nosuf=${asm%.fa}
split_asm="${asm_nosuf}_split.fa"

#first 11 scaffolds are above 500MB. These will be split.

seqkit sliding -g -s ${maxlen} -W ${maxlen} ${asm} | \
awk '{ if ($0 ~ /^>/) {
  split($1,m,"_")
  scaffnum=m[2]*1

  if (scaffnum < 12) {
    if ($0 ~ "sliding:1-") {
      frag=1
    } else if ($0 ~ "sliding:500000001-") {
      frag=2
    } else if ($0 ~ "sliding:1000000001-") {
      frag=3
    } else if ($0 ~ "sliding:1500000001-") {
      frag=4
    } else if ($0 ~ "sliding:2000000001-") {
      frag=5
    } else {
      lastfrag+=1
      frag=lastfrag
    }

    $1=">scaffold_" scaffnum "_primary_" frag
    print
  } else {
    $1=">scaffold_" scaffnum "_primary"
    print
  }
} else {
  print
}
}' > ${split_asm} && samtools faidx ${split_asm}
