#!/bin/bash

#split .fai into scaffolds
for scaffold in $(cat scaffolds.txt) ; do
  grep "${scaffold}_" interior_primary_1Mb_broken.fa.fai > ${scaffold}.fa.fai
  len=$(wc -l ${scaffold}.fa.fai | cut -d ' ' -f1)
  len_minus1=$(echo $((${len}-1)))
  touch tmp_${scaffold}.txt
  for len in $(cut -f2 ${scaffold}.fa.fai | head -n ${len_minus1}) ; do
    new=$(echo $((${len}+200)))
    echo -e "${len}\t${new}" >> tmp_${scaffold}.txt
  done
  last=$(tail -n1 ${scaffold}.fa.fai | cut -f2)
  echo -e "${last}\t${last}" >> tmp_${scaffold}.txt
done

cut -f1 interior_primary_1Mb_broken.fa.fai > names.txt
touch tmp.txt
for scaffold in $(cat scaffolds.txt) ; do
  cat tmp_${scaffold}.txt >> tmp.txt
done
paste names.txt tmp.txt > contig_lengths_adjusted.tsv
