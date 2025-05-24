#!/bin/bash

#split .fai into scaffolds; add gaps (200N) to each contig, except the last
for scaffold in $(cat scaffolds.txt) ; do
  grep "${scaffold}_" interior_primary_1Mb_broken.fa.fai > ${scaffold}.fa.fai
  length=$(wc -l ${scaffold}.fa.fai | cut -d ' ' -f1)
  len_minus1=$(echo $((${length}-1)))
  touch tmp_${scaffold}.txt
  for len in $(cut -f2 ${scaffold}.fa.fai | head -n ${len_minus1}) ; do
    new=$(echo $((${len}+200)))
    echo "${new}" >> tmp_${scaffold}.txt
  done
  last=$(tail -n1 ${scaffold}.fa.fai | cut -f2)
  echo -e "${last}" >> tmp_${scaffold}.txt
  cut -f1 ${scaffold}.fa.fai | paste - tmp_${scaffold}.txt > contig_lengths_adjusted_${scaffold}.tsv
done

#check lengths
touch scafflengths_check.txt
for scaffold in $(cat scaffolds.txt) ; do
  cut -f2 contig_lengths_adjusted_${scaffold}.tsv | paste -sd+ - | bc >> scafflengths_check.txt 
done
cut -f2 interior_primary_1Mb.fa.fai | paste - scafflengths_check.txt | less #they match!

#Create the index
for scaffold in $(cat scaffolds.txt) ; do
  new=(0)
  contig_lengths=($(cut -f2 contig_lengths_adjusted_${scaffold}.tsv))
  numlines=$(wc -l contig_lengths_adjusted_${scaffold}.tsv | cut -d ' ' -f1)
  numlines_minus1=$(echo $((${numlines}-1)))
  for i in $(seq 1 ${numlines_minus1}) ; do
    h=$(echo $((${i}-1)))
    new[$i]=$(echo $((${contig_lengths[$h]}+${new[$h]})))
  done
  printf '%s\n' "${new[@]}" > foo.txt
  cut -f1 contig_lengths_adjusted_${scaffold}.tsv | paste - foo.txt > ${scaffold}.idx && rm foo.txt
done

