#!/bin/bash

module load bedtools/2.31.1 genometools/1.6.2

anndir=/core/projects/EBP/smith/eviann/eviann_int_allvdata_new
annotation=interior_primary_mancur_masked_500kb.fa.pseudo_label.gff
filt_annotation=interior_primary_mancur_masked_500kb.fa.no_pseudo_overlap.gff
filt_annotation_pseudo=interior_primary_mancur_masked_500kb.fa.no_overlap.gff

#format genes as bed
awk -F "\t" -v OFS="\t" '$0 ~ !/^#/ && $3 == "gene" {
  split($9,m,";")
  split(m[1],n,"=")
  print $1,$4,$5,n[2]
}' ${annotation} > genes_unfiltered.bed

#sort (first by chr, then by start coordinate)
cut -f 1 genes_unfiltered.bed | sort -t "_" -k2,2 -g | uniq > scaffolds.txt
touch genes_unfiltered.s.bed
for scaffold in $(cat scaffolds.txt) ; do
  awk -v OFS="\t" -v scaffold="$scaffold" -F "\t" '{
    if ($1 == scaffold) {
      print
    }
  }' genes_unfiltered.bed | sort -g -k2,2 >> genes_unfiltered.s.bed
done

#this tool merges records that overlap - this is a test for overlapping genes
bedtools merge -c 4 -o distinct -i genes_unfiltered.s.bed > genes_merged.bed

#find any loci that overlap each other
awk -F "\t" -v OFS="\t" '{
  n=split($4,m,",")
  if (n > 1) {
    print
  }
}' genes_merged.bed > genes_overlapping.bed
cut -f4 genes_overlapping.bed | sed 's/,/\n/g' | sort -d | uniq > overlapping_loci.txt

#find pseudogene_loci
awk -F "\t" -v OFS="\t" '{
  if ($0 ~ /^#/) {
    next
  }
  if ($3 == "gene" && $9 ~ "pseudo=true") {
    split($9,m,";")
    split(m[1],n,"=")
    print n[2]
  }
}' ${annotation} > pseudogene_loci.txt

#create a blacklist
cat overlapping_loci.txt pseudogene_loci.txt | sort -d | uniq > blacklist.txt

#filter gff (for some reason this prints headers twice, filtering for that at the end)
awk -v OFS="\t" -F "\t" 'NR==FNR{
  #build an array where the key is the blacklisted loc
  arr[$1]=1
  next
}{
  if ($0 ~ /^#/) {
    #print the header
    print
  } else if ($3 == "gene") {
    #if its a gene, the geneid is first rec
    split($9,m,";")
    split(m[1],n,"=")
    id=n[2]
  } else {
    #if its not a gene, the first rec is associated w/ a transcript
    split($9,m,";")
    split(m[1],n,"=")
    split(n[2],o,"-")
    id=o[1]
  }
  #if the geneid is in the blacklist array, skip it
  if (id in arr) {
    next
  } else {
    print
  }
}' blacklist.txt ${annotation} | \
awk -F "\t" -v OFS="\t" 'NR==1 || NR==3 || NR==4 { next } {print}' > ${filt_annotation}

#make a gff with pseudogenes but no overlaps
cat overlapping_loci.txt > blacklist.txt
awk -v OFS="\t" -F "\t" 'NR==FNR{
  #build an array where the key is the blacklisted loc
  arr[$1]=1
  next
}{
  if ($0 ~ /^#/) {
    #print the header
    print
  } else if ($3 == "gene") {
    #if its a gene, the geneid is first rec
    split($9,m,";")
    split(m[1],n,"=")
    id=n[2]
  } else {
    #if its not a gene, the first rec is associated w/ a transcript
    split($9,m,";")
    split(m[1],n,"=")
    split(n[2],o,"-")
    id=o[1]
  }
  #if the geneid is in the blacklist array, skip it
  if (id in arr) {
    next
  } else {
    print
  }
}' blacklist.txt ${annotation} | \
awk -F "\t" -v OFS="\t" 'NR==1 || NR==3 || NR==4 { next } {print}' > ${filt_annotation_pseudo}

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
}' $filt_annotation > tmp_parsed_annotation.gff

#infer introns

gt gff3 -sort yes -retainids yes -addintrons yes \
tmp_parsed_annotation.gff > "${filt_annotation%.gff}_wintrons.gff"
