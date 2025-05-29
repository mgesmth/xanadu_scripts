#!/bin/bash
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 12
#SBATCH --mem=36G
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

set -f

cd /home/FCAM/msmith/svs/intersect
idx=/home/FCAM/msmith/svs/minigraph_out/contig2scaffoldpos.idx
touch new_scaffolded.bed
#With the index, translate the coordinates of the SV vcf from contig-scale to scaffold-scale
#Now for the records:
cat new.bed | while read -r rec; do
  #Contig name
  contig=$(echo ${rec} | cut -d ' ' -f1)
  #Variant start
  start=$(echo ${rec} | cut -d ' ' -f2)
  #Variant end
  end=$(echo ${rec} | cut -d ' ' -f3)
  #Grab the appropriate contig from the index
  s=$(grep -w "$contig" ${idx} | cut -f2)
  new_start=$(echo $((${start}+${s})))
  new_end=$(echo $((${end}+${s})))
  echo ${rec} | sed "s/${start}/${new_start}/g" | sed "s/${end}/${new_end}/g" | sed "s/ /\t/g" >> new_scaffolded.bed
done

