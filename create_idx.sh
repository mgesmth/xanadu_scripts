#!/bin/bash

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

