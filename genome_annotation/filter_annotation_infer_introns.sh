#!/bin/bash

if [[ ( $@ == "--help") ||  $@ == "-h" ]]
then
    echo ""
    echo "Usage: ./filter_annotation_infer_introns.sh -g <INFILE.gff3> -m <transcripts.fasta> -p <proteins.fasta> -o <OUTPUT>"
    echo ""
    echo "Filter out overlapping gene records and infer introns from EviAnn generated annotation."
    echo ""
    echo "Requirements:"
    echo "  bedtools"
    echo "  genometools"
    echo ""
    echo "-g <INFILE.gff3>          Annotation file."
    echo "-m <transcripts.fasta>    mRNA transcript fasta file."
    echo "-p <proteins.fasta>       Peptide fasta file"
    echo "-o <OUTPUT>               A prefix for output files."
    echo ""
    echo ""
  exit 0
fi

threads=1

OPTSTRING="g:m:p:o:"
while getopts ${OPTSTRING} opt
do
case ${opt} in
  g) gff=${OPTARG};;
  m) mrna=${OPTARG};;
  p) pep=${OPTARG};;
  o) out=${OPTARG};;
  ?)
    echo "invalid option: -${opt}"
    exit 1 ;;
  esac
done

if [[ -z ${gff} || -z ${mrna} || -z ${pep} || -z ${out} ]] ; then
  echo "[E]: Options -g, -m, -p and -o require arguments. Exiting."
  echo "[E]: Run ./filter_annotation_infer_introns.sh -h or --help to see detailed usage."
  exit 1
fi

out_gff="${out}.filtered.gff3"
out_gff_introns="${out}.filtered.introns.gff3"
out_mrna="${out}.filtered.transcripts.fasta"
out_pep="${out}.filtered.proteins.fasta"

#format genes as bed
awk -F "\t" -v OFS="\t" '$0 ~ !/^#/ && $3 == "gene" {
  split($9,m,";")
  split(m[1],n,"=")
  print $1,$4,$5,n[2]
}' ${gff} > genes_unfiltered.bed

#sort (first by chr, then by start coordinate)
cut -f 1 genes_unfiltered.bed | sort -t "_" -k3,3 -g | uniq > scaffolds.txt
touch genes_unfiltered.s.bed
for scaffold in $(cat scaffolds.txt) ; do
  awk -v OFS="\t" -v scaffold="$scaffold" -F "\t" '{
    if ($1 == scaffold) {
      print
    }
  }' genes_unfiltered.bed | sort -g -k2,2 >> genes_unfiltered.s.bed
done && rm genes_unfiltered.bed

#this tool merges records that overlap - this is a test for overlapping genes
bedtools merge -c 4 -o distinct -i genes_unfiltered.s.bed > genes_merged.bed && rm genes_unfiltered.s.bed

#find any loci that overlap each other
awk -F "\t" -v OFS="\t" '{
  n=split($4,m,",")
  if (n > 1) {
    print
  }
}' genes_merged.bed > genes_overlapping.bed
cut -f4 genes_overlapping.bed | sed 's/,/\n/g' | sort -d | uniq > overlapping_loci.txt && rm genes_overlapping.bed

#create a blacklist
sort -d overlapping_loci.txt | uniq > blacklist.txt && rm overlapping_loci.txt

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
}' blacklist.txt ${gff} | \
awk -F "\t" -v OFS="\t" 'NR==1 || NR==3 || NR==4 { next } {print}' > ${out_gff}

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
}' ${out_gff} > tmp_parsed_annotation.gff

#infer introns

gt gff3 -sort yes -retainids yes -addintrons yes \
tmp_parsed_annotation.gff > "${out_gff_introns}" && rm tmp_parsed_annotation.gff 

#remove blacklisted transcripts and proteins
awk 'BEGIN { skip=0 }
} FNR==NR {
  blacklist[$1]=1
  next
} $0 ~ /^>/ {
  split(substr($1,2),m,"-")
  if (m[1] in blacklist) {
    skip=1
  } else {
    skip=0
    print
  }
  next
} {
  if (skip == 0) {
    print
  }
  next
}' ${mrna} > ${out_mrna}

awk 'BEGIN { skip=0 }
} FNR==NR {
  blacklist[$1]=1
  next
} $0 ~ /^>/ {
  split(substr($1,2),m,"-")
  if (m[1] in blacklist) {
    skip=1
  } else {
    skip=0
    print
  }
  next
} {
  if (skip == 0) {
    print
  }
  next
}' ${pep} > ${out_pep}

mv blacklist.txt "${out}.blacklisted_genes.txt"
len_blacklist=$(cat ${out}.blacklisted_genes.txt | wc -l)
echo "[M]: Identified ${len_blacklist} overlapping genes, which were filtered out."
echo "[M]: Their geneIDs can be found in ./${out}.blacklisted_genes.txt."
echo "[M]: Filtered annotation: ./${out_gff}"
echo "[M]: Filtered annotation with introns: ./${out_gff_introns}"
echo "[M]: Filtered mRNA transcripts: ./${out_mrna}"
echo "[M]: Filtered peptides: ./${out_pep}"



