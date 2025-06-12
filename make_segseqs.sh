#!/bin/bash
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 4
#SBATCH -n 1
#SBATCH --mem=25G
#SBATCH --array=0-630%70
#SBATCH -o %x.%A.%a.out
#SBATCH -e %x.%A.%a.err

echo `hostname`

home=/home/FCAM/msmith
scratch=/scratch/msmith
splitdir=${home}/svs/minigraph_out/segments_split
outdir=${home}/svs/minigraph_out/SV_sequences
cd ${splitdir}

files=($(cat chunks.txt))
file=${files[$SLURM_ARRAY_TASK_ID]}
pangraph=${home}/svs/minigraph_out/all_brokenscaffolds.gfa

echo "Welcome to task ${SLURM_ARRAY_TASK_ID}, where we are working with ${file}."

outfile="${outdir}/SV_sequences/${file}.fa"
tmpfile="${scratch}/tmp_${file}.fa"

touch ${outfile}

for line in $(cat "$file") ; do
  segs=$(echo "$line" | cut -f2)
  SV_num=$(echo "$line" | cut -f1)
  gfatools view -l "$segs" ${pangraph} | gfatools gfa2fa > ${tmpfile}
  awk -v SV_num="$SV_num" '/^>/ {print $0"_"SV_num} !/^>/ {print}' ${tmpfile} >> ${outfile}
done && echo "Task ${SLURM_ARRAY_TASK_ID} complete."
