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

indir=/home/FCAM/msmith/svs/minigraph_out/split
outdir=/scratch/msmith/classifying_repeat
cd ${outdir}

chunks=($(ls -1 ${indir}/chunk_*))
file=${chunks[$SLURM_ARRAY_TASK_ID]}

cat ${file} | while read -r line ; do
  recname=$(echo "$line" | awk '{print $1":"$2"-"$3}')
  segs=$(echo "$line" | cut -f12)
  gfatools view -l "$segs" ${indir}/all_brokenscaffolds.gfa > "$recname".gfa
  gfatools gfa2fa tmp.gfa > "$recname".fa
  rm "$recname".gfa
done
