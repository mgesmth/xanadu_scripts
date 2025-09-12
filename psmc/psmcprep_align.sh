#!/bin/bash
#SBATCH -J align_hifi
#SBATCH -p general
#SBATCH -q general
#SBATCH -n 1
#SBATCH -c 8
#SBATCH --mem=40G
#SBATCH --array=[0-299]
#SBATCH -o %j.%A.%a.out
#SBATCH -e %j.%A.%a.err

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

FILES=($(cat ${hifidir}/chunks.txt))
FQ=${FILES[$SLURM_ARRAY_TASK_ID]}
base_fq=$(basename ${FQ})
base_prim=$(basename ${prim})
outfile="${outdir}/hifialn_${base}.bam"
tmpfile="${core}/hifi_tmp/minitmp_${SLURM_ARRAY_TASK_ID}"

echo "[M]: Welcome to minimap alignment task ${SLURM_ARRAY_TASK_ID}."
echo "[M]: We are aligning ${base_fq} to ${base_prim}."

${home}/scripts/minimap2_hifi.sh -s 4 -t 4 -r "$prim" -q "$FQ" -o "$outfile" -x "$tmpfile"
if [[ $? -eq 0 ]]; then
  date
  echo "[M]: Alignment complete."
  rm "$FQ"
else
  echo "[E]: Alignment failed."
  exit 1
fi
