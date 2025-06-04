#!/bin/bash
#SBATCH -J getseq
#SBATCH -p general
#SBATCH -q general
#SBATCH -n 1
#SBATCH -c 4
#SBATCH --mem=10G
#SBATCH --array=0-630%100
#SBATCH -o %x.%a.%A.out
#SBATCH -e %x.%a.%A.err

echo `hostname`

export PATH="/core/projects/EBP/smith/bin/gfatools:$PATH"

bed=/home/FCAM/msmith/minigraph_out/all_brokenscaffolds.gfa
indir=/home/FCAM/msmith/svs/minigraph_out/split
outdir=/scratch/msmith/classifying_repeat
cd ${outdir}

chunks=($(ls -1 ${indir}/chunk_*))
file=${chunks[$SLURM_ARRAY_TASK_ID]}

base=$(basename "$file")
touch "$base".fa
cat ${file} | while read -r line ; do
  recname=$(echo "$line" | awk '{print $1":"$2"-"$3}')
  segs=$(echo "$line" | cut -f12)
  gfatools view -l "$segs" ${bed} > "$recname".gfa
  gfatools gfa2fa "$recname".gfa >> "$base".fa
  rm "$recname".gfa
done
