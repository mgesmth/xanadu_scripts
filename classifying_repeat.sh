#!/bin/bash
#SBATCH -J getseq
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 12
#SBATCH --mem=36G
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

echo `hostname`

export PATH="/core/projects/EBP/smith/bin/gfatools:$PATH"

indir=/home/FCAM/msmith/svs/minigraph_out
outdir=/scratch/msmith/classifying_repeat
cd ${outdir}
cat ${indir}/all_brokenscaffolds_verified.bed | while read -r line ; do
  recname=$(echo "$line" | awk '{print $1":"$2"-"$3}')
  segs=$(echo "$line" | cut -f12)
  gfatools view -l "$segs" ${indir}/all_brokenscaffolds.gfa > tmp.gfa
  gfatools gfa2fa tmp.gfa > "$recname".fa
  rm tmp.gfa
done
