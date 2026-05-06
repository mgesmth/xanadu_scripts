#!/bin/bash

module load seqkit/2.10.0 samtools/1.19

core=/core/projects/EBP/smith
asmdir=${core}/final_genome
asm=${asmdir}/interior_primary_final.FINAL.fasta
nosuf=${asm%.fasta}

cd ${asmdir}
#fix scaffold names and isolate the major 12
awk 'BEGIN { scaff_counter=0 } $0 ~ /^>/ {
  scaffold_counter+=1
  if (scaffold_counter > 12) {
    exit
  }
  gsub("HiC_","",$1)
  $1=$1 "_primary"
  print
  next
}{
  print
}' ${asm} > ${nosuf}_header.fa

splitasm="${nosuf}_split.fa"
seqkit sliding -g -s 1000000000 -W 1000000000 ${nosuf}_header.fa | \
awk '{ if ($0 ~ /^>/) {
  split($1,m,"_")
  scaffnum=m[2]*1

  if (scaffnum < 13) {
    if ($0 ~ "sliding:1-") {
      frag=1
    } else if ($0 ~ "sliding:1000000001-") {
      frag=2
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
}' > ${splitasm} && samtools faidx ${splitasm}
