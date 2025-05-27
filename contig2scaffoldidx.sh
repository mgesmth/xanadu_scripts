#!/bin/bash

#split .fai into scaffolds; add gaps (200N) to each contig, except the last contig, which wouldn't have a trailing gap
for scaffold in $(cat scaffolds.txt) ; do
  grep "${scaffold}_" interior_primary_1Mb_broken.fa.fai > ${scaffold}.fa.fai
  length=$(wc -l ${scaffold}.fa.fai | cut -d ' ' -f1)
  #last contig does not need a gap added to it; exclude from inner loop
  len_minus1=$(echo $((${length}-1)))
  touch tmp_${scaffold}.txt
  for len in $(cut -f2 ${scaffold}.fa.fai | head -n ${len_minus1}) ; do
    new=$(echo $((${len}+200)))
    echo "${new}" >> tmp_${scaffold}.txt
  done
  #add the last contig as is
  last=$(tail -n1 ${scaffold}.fa.fai | cut -f2)
  echo -e "${last}" >> tmp_${scaffold}.txt
  cut -f1 ${scaffold}.fa.fai | paste - tmp_${scaffold}.txt > contig_lengths_adjusted_${scaffold}.tsv
  rm tmp_${scaffold}.txt ${scaffold}.fa.fai
done

#check lengths to ensure the sum of contig lengths (with 200N gaps) matches the scaffold length from the index
touch scafflengths_check.txt
for scaffold in $(cat scaffolds.txt) ; do
  cut -f2 contig_lengths_adjusted_${scaffold}.tsv | paste -sd+ - | bc >> scafflengths_check.txt 
done
cut -f2 interior_primary_1Mb.fa.fai | paste - scafflengths_check.txt | less #they match!

#Create the index - what number would I need to add to the coordinates of each contig to make it correspond to the scaffold rather than the contig?
#For scaffold1_52 position 1, for example, is 1 + (sum of the lengths of contigs 1-51)
touch contig2scaffoldpos.idx
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
  cat ${scaffold}.idx >> contig2scaffoldpos.idx
done

#With the index, translate the coordinates of the SV vcf from contig-scale to scaffold-scale
##NOTE: foo.vcf is the same as all_dougfir_allthree_altall.sv.vcf but with contig names changed to match index
##print the header of the VCF to the new vcf
awk '/^#/ {print $0}' foo.vcf > all_dougfir_scaffcoord.sv.vcf
#Now for the records:
awk '!/^#/' foo.vcf | while read -r rec; do
  #Contig name
  contig=$(echo ${rec} | cut -d ' ' -f1)
  #Variant start
  start=$(echo ${rec} | cut -d ' ' -f2)
  #Variant end is embedded in the info field
  end=$(echo "$rec" | grep -o 'END=[0-9]*' | cut -d= -f2)
  #Grab the appropriate contig from the index
  s=$(grep -w "$contig" contig2scaffoldpos.idx | cut -f2)
  new_start=$(echo $((${start}+${s})))
  new_end=$(echo $((${end}+${s})))
  echo ${rec} | sed "s/${start}/${new_start}/g" | sed "s/${end}/${new_end}/g" | sed "s/ /\t/g" >> all_dougfir_scaffcoord.sv.vcf
done



