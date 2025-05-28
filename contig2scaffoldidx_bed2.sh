#!/bin/bash
#SBATCH -p himem2
#SBATCH -q himem
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 2
#SBATCH --mem=12G
#SBATCH --array=0-12
#SBATCH -o %A.%a.out
#SBATCH -e %A.%a.err

cd /home/FCAM/msmith/svs/intersect/chunk
FILES=($(ls -1 chunk_*))
idx=/home/FCAM/msmith/svs/minigraph_out/contig2scaffoldpos.idx
F=${FILES[$SLURM_ARRAY_TASK_ID]}
OUT=$(echo "${FILES[$SLURM_ARRAY_TASK_ID]}.out") 
touch ../out/${OUT}
#With the index, translate the coordinates of the SV vcf from contig-scale to scaffold-scale
#Now for the records:
for rec in $(cat ${F}); do
  #Contig name
  contig=$(echo ${rec} | cut -d ' ' -f1)
  #Variant start
  start=$(echo ${rec} | cut -d ' ' -f2)
  #Variant end is embedded in the info field
  end=$(echo ${rec} | cut -d ' ' -f3)
  #Grab the appropriate contig from the index
  s=$(grep -w "$contig" ${idx} | cut -f2)
  new_start=$(echo $((${start}+${s})))
  new_end=$(echo $((${end}+${s})))
  echo ${rec} | sed "s/${start}/${new_start}/g" | sed "s/${end}/${new_end}/g" | sed "s/ /\t/g" >> ../out/${OUT}
done

