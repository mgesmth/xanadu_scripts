#!/bin/bash
#SBATCH -J minimap_arr
#SBATCH -p general
#SBATCH -q general
#SBATCH -n 1
#SBATCH -c 6
#SBATCH --mem=20G
#SBATCH --array=0-x%15
#SBATCH -o %j.%A.%a.out
#SBATCH -e %j.%A.%a.err

echo "[M]: Hostname: `hostname`"

home=/home/FCAM/msmith
core=/core/projects/EBP/smith
scratch=/scratch/msmith
hifidir=${scratch}/hifi_split
prim=${core}/CBP_assemblyfiles/interior_primary_final.fa
out=${scratch}/hifi_out

module load samtools/1.19.2
module load minimap2/2.28

FILES=($(ls -1 ${hifidir}/hifisplit_*))
FQ=${FILES[$SLURM_ARRAY_TASK_ID]}
base=$(basename ${FQ})

echo "[M]: Welcome to minimap alignment task ${SLURM_ARRAY_TASK_ID}."

${home}/scripts/minimap2_hifi.sh -s 2 -t 4 -r "$prim" -q "$FQ" -o "${out}_${SLURM_ARRAY_TASK_ID}.bam"
if [[ $? -eq 0 ]]; then
rm "$FQ"
else
exit 1
fi
