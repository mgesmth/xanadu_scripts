#!/bin/bash

touch all_scaffolded.bed
#With the index, translate the coordinates of the SV vcf from contig-scale to scaffold-scale
#Now for the records:
cat all_brokenscaffolds.bed | while read -r rec; do
  #Contig name
  contig=$(echo ${rec} | cut -d ' ' -f1)
  #Variant start
  start=$(echo ${rec} | cut -d ' ' -f2)
  #Variant end is embedded in the info field
  end=$(echo "$rec" | cut -d ' ' -f3)
  #Grab the appropriate contig from the index
  s=$(grep -w "$contig" contig2scaffoldpos.idx | cut -f2)
  new_start=$(echo $((${start}+${s})))
  new_end=$(echo $((${end}+${s})))
  echo ${rec} | sed "s/${start}/${new_start}/g" | sed "s/${end}/${new_end}/g" | sed "s/ /\t/g" >> all_scaffolded.bed
done



