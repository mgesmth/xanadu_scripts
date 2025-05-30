#!/bin/bash
#SBATCH -J redo
#SBATCH -p general
#SBATCH -q general
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --array=[0-12]
#SBATCH -o %x.%A.%a.out
#SBATCH -e %x.%A.%a.err

cd /home/FCAM/msmith/svs/minigraph_out/chunk
files=($(ls -1 chunk_a*))
file=${files[$SLURM_ARRAY_TASK_ID]}
output="${file}.out"
touch out/${output}
#Now for the records:
cat ${file} | while read -r rec; do
  add=$(echo "$rec" | cut -f1 | grep -wf - ../contig2scaffoldpos.idx | cut -f2)
  echo "$rec" | awk -v a="$add" 'BEGIN { OFS="\t" } {
    start=$2
    split($8, m, ";", sepsm)
    split(m[1], n, "=", sepsn)
    end=n[2]
    new_start=start+a
    new_end=end+a
    sub(/END=[0-9]+/, "END=" new_end, $8)
    print $1,new_start,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12 }' >> out/${output}
done

