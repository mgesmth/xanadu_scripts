#!/bin/bash
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 10
#SBATCH --mem=20G
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

echo `hostname`

cd /home/FCAM/msmith/minigraph_out

awk '!/^#/' foo.vcf | while read -r rec; do
  contig=$(echo ${rec} | cut -d ' ' -f1)
  start=$(echo ${rec} | cut -d ' ' -f2)
  end=$(echo "$rec" | grep -o 'END=[0-9]*' | cut -d= -f2)
  s=$(grep -w "$contig" contig2scaffoldpos.idx | cut -f2)
  new_start=$(echo $((${start}+${s})))
  new_end=$(echo $((${end}+${s})))
  echo ${rec} | sed "s/${start}/${new_start}/g" | sed "s/${end}/${new_end}/g" | sed "s/ /\t/g" >> all_dougfir_scaffcoord.sv.vcf
done
