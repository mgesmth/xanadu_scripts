#!/bin/bash

#samtools version 1.21
module load seqkit/2.10.0 samtools

dir=/core/projects/EBP/smith/final_genome
asm=${dir}/psme_glauca_primary.fasta
splitasm=${dir}/psme_glauca_primary_bigscaffoldsplit.fa
split_size=1000000000

seqkit sliding \
  -g -W ${split_size} -s ${split_size} \
  ${asm} | \
  awk -v split_size="$split_size" ' BEGIN {
    full_interval_motif="sliding:1-" split_size
  } $0 ~ /^>/ {
    #rename the fragments (not "sliding:1-x")
    if ($1 ~ "sliding:1-") {
      #is the first fragment
      if ($1 ~ full_interval_motif) {
        frag=1
      } else {
        #if not the full interval motif, is just a scaffold smaller than the split size - no frag necessary
        frag=0
      }
    } else {
      #doesnt start at base 1. This is "next" fragment
      #this will reset when you encounter the next "sliding:1-""
      frag+=1
    }
    n=split($1,m,"_")
    #get the last element of the split header: this is the "sliding:x"
    sliding_motif="_" m[n]
    gsub(sliding_motif,"",$1)

    chr=$1
    if (frag > 0) {
      $1=chr "_" frag
    } else {
      #if frag is 0, an unsplit scaffold
      $1=chr
    }
    print
    next
  } {
    #is a sequence line
    print
  }' > $splitasm

#check it worked the way you expected
samtools faidx $splitasm
