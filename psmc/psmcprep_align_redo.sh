#!/bin/bash
#SBATCH -J align_hifi
#SBATCH -p general
#SBATCH -q general
#SBATCH -n 1
#SBATCH -c 12
#SBATCH --mem=60G
#SBATCH --array=[0-3]
#SBATCH -o %x.%A.%a.out
#SBATCH -e %x.%A.%a.err

#some tasks failed. redoing.

echo "[M]: Hostname: `hostname`"

home=/home/FCAM/msmith
core=/core/projects/EBP/smith
scratch=/scratch/msmith
hifidir=${scratch}/hifi_split
prim=${core}/manual_curation_files/interior_primary_final_mancur2.fa
outdir=${scratch}/hifi_out

module load samtools/1.20
module load minimap2/2.28

cd ${hifidir}

FILES=($(cat ${hifidir}/chunks_redo.txt))
FQ=${FILES[$SLURM_ARRAY_TASK_ID]}
base_fq=$(basename ${FQ})
base_prim=$(basename ${prim})
num=$(echo "$base_fq" | cut -f1 -d '.' | sed 's/hifi_split0//g')
outfile="${outdir}/hifialn_${num}.bam"
tmpfile="${core}/hifi_tmp/minitmp_${SLURM_ARRAY_TASK_ID}"

echo "[M]: Welcome to minimap alignment task ${SLURM_ARRAY_TASK_ID}."
echo "[M]: We are aligning ${base_fq} to ${base_prim}."

${home}/scripts/minimap2_hifi.sh -s 6 -t 6 -r "$prim" -q "$FQ" -o "$outfile" -x "$tmpfile"
if [[ $? -eq 0 ]]; then
  date
  echo "[M]: Alignment complete."
  rm "$FQ"
else
  echo "[E]: Alignment failed."
  exit 1
fi
