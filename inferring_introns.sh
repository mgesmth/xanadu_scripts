#!/bin/bash

module load genometools/1.6.2 bedtools/2.29.0
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

#find pseudogene loci
awk -F "\t" -v OFS="\t" '{
  if ($3 == "gene" && $9 ~ "pseudo=true") {
    split($9,m,";")
    split(m[1],n,"=")
    print n[2]
  }}' tmp_introns.gff3 > pseudogene_loci.txt

#get all genes to see if they overlap
awk -F "\t" -v OFS="\t" '{
  if ($3 == "gene") {
    split($9,m,";")
    split(m[1],n,"=")
    print $1,$4,$5,n[2]
  }
}' tmp_introns.gff3 > genes.txt

##sort genes
cut -f 1 genes.txt | sort -t "_" -k2,2 -g | uniq > scaffolds.txt
touch genes.s.txt
for scaffold in $(cat scaffolds.txt) ; do
  awk -v OFS="\t" -v scaffold="$scaffold" -F "\t" '{
    if ($1 == scaffold) {
      print
    }
  }' genes.txt | sort -g -k2,2 >> genes.s.txt
done

bedtools merge -c 4 -o distinct -i genes.s.txt > genes_merged.s.txt

awk -v OFS="\t" -F "\t" '{
  n=split($4,m,",")
  if (n > 1) {
    print
  } else {
    next
  }
}' genes_filt_merged.s.txt > overlapping_genes.txt

cut -f4 overlapping_genes.txt | sed 's/,/\n/g' | sort -d | uniq > overlapping_loci.txt
#this ^ is the list of loci that overlap

cat overlapping_loci.txt pseudogene_loci.txt | sort -d | uniq > blacklist.txt

awk -v OFS="\t" -F "\t" 'NR==FNR{
  arr[$1]=1
  next
}{
  if ($3 == "gene") {
    split($9,m,";")
    split(m[1],n,"=")
    id=n[2]
  } else {
    split($9,m,";")
    split(m[1],n,"=")
    split(n[2],o,"-")
    id=o[1]
  }
  if (id in arr) {
    next
  } else {
    print
  }
}' blacklist.txt tmp_introns.gff3 > tmp_introns_filt.gff3


awk -F "\t" -v OFS="\t" '{
  if ($3 == "intron") {
    print
  } else {
    next
  }
}' tmp_introns.gff3 | less
