#!/bin/bash

module load seqkit/2.10.0 samtools/1.19

core=/core/projects/EBP/smith
asm_full=${core}/3ddna_again/interior_primary_final.FINAL.fasta
asm_500kb=${core}/linkage_snp_calling/03_genome/interior_primary_final.FINAL.500kb.fasta

scaff=$(awk -F "\t" '$2 >= 1000000 { next } { print $1 ; exit }' ${asm_full}.fai)
linenum=$(($(grep -n -w ">${scaff}" | cut -f1 -d ":")-1))
head -n ${linenum} ${asm_full} > ${asm_500kb}

maxlen=500000000

asm=$(basename ${asm_500kb})
asm_nosuf=${asm%.fasta}
split_asm="${asm_nosuf}_split.fa"

#12 scaffolds are above 500MB. These will be split.
seqkit sliding -g -s ${maxlen} -W ${maxlen} ${asm} | \
awk '{ if ($0 ~ /^>/) {
  split($1,m,"_")
  scaffnum=m[3]*1

  if (scaffnum < 13) {
    if ($0 ~ "sliding:1-") {
      frag=1
    } else if ($0 ~ "sliding:500000001-") {
      frag=2
    } else if ($0 ~ "sliding:1000000001-") {
      frag=3
    } else if ($0 ~ "sliding:1500000001-") {
      frag=4
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
rm ${asm_500kb}
