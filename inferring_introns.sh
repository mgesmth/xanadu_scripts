#!/bin/bash

annotation=$1

#I'm using genometools here, and it was having trouble with my annotations that came from protein db evidence due to formatting
awk -F "\t" -v OFS="\t" '{
  n=split($9,m,";")
  if ($0 ~ /^#/) {
    print
  } else if ($9 ~ "EvidenceProteinID") {
    o=n-1
    $9=m[1] ";" m[2] ";" m[o] ";" m[n]
    print
  } else if ($9 ~ "EvidenceTranscriptID" && m[1] ~ "XLOC") {
    $9=m[1] ";" m[2] ";" m[n]
    print
  } else {
    print
  }
}' $annotation > tmp_parsed_annotation.gff

gt gff3 -sort yes -retainids yes -addintrons yes tmp_parsed_annotation.gff > tmp_introns.gff3

awk -F "\t" -v OFS="\t" '{
  if ($3 == "intron") {
    print
  } else {
    next
  }
}' tmp_introns.gff3 | less
