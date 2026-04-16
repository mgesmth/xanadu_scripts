#!/bin/bash

fai=interior_primary_mancur_masked_500kb.fa.fai

head -n12 $fai | \
cut -f1,2 | \
sed 's/HiC_scaffold_/chr/g' > genome_12.txt

ann=interior_primary_mancur_masked_500kb.fa.no_pseudo_overlap_wintrons.gff
#get gene records: chr, start, end, geneid
awk -F "\t" -v OFS="\t" '{
  if ($3 == "gene") {
    split($1,m,"_")
    if (m[3]*1 < 13) {
      gsub("HiC_scaffold_","chr",$1)
      split($9,n,";")
      id=substr(n[1],4)
      print $1,$4,$5,id
    } else {
      next
    }
  } else {
    next
  }
}' $ann > genes.tsv

# get intron records: chr, start, end, geneid
awk -F "\t" -v OFS="\t" '{
  if ($3 == "intron") {
    split($1,m,"_")
    if (m[3]*1 < 13) {
      gsub("HiC_scaffold_","chr",$1)
      gsub("Parent=","",$9)
      split($9,n,"-")
      id=n[1]
      print $1,$4,$5,id
    } else {
      next
    }
  } else {
    next
  }
}' ${ann} > introns.tsv

touch introns.s.tsv
for i in $(seq 1 12) ; do
  grep -w "chr${i}" introns.tsv | sort -g -k2,2 >> introns.s.tsv
done

bedtools merge

repeats=repeatMasker_merged_bestmatch.out

#from concatenated .out RepeatMasker file (filtered for only best alignments), get chr, start, end, repeat type
awk -F "\t" -v OFS="\t" '{
  if ($1 ~ /^SW_/) {
    next
  } else {
    split($5,m,"_")
    if (m[3] < 13) {
      gsub("HiC_scaffold_","chr",$5)
      print $5,$6,$7,$11
    } else {
      next
    }
  }
}' ${repeats} > repeats.tsv
