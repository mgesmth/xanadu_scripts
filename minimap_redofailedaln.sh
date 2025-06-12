#!/bin/bash
#SBATCH --job-name=minimap_arr
#SBATCH -p general
#SBATCH -q general
#SBATCH -n 1
#SBATCH -c 8
#SBATCH --mem=40G
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

echo "[M]: Hostname: `hostname`"

home=/home/FCAM/msmith
core=/core/projects/EBP/smith
scratch=/scratch/msmith
hifidir=${scratch}/hifi_split
prim=${core}/CBP_assemblyfiles/interior_primary_final.fa
outdir=${scratch}/hifi_out

module load samtools/1.20
module load minimap2/2.28

cd ${hifidir}

FQ=${hifidir}/hifisplit_am
base=$(basename ${FQ})
outfile="${outdir}/hifialn_${base}.bam"
tmpfile="${scratch}/minitmp_${SLURM_ARRAY_TASK_ID}"

echo "[M]: Welcome to minimap alignment task ${SLURM_ARRAY_TASK_ID}."

${home}/scripts/minimap2_hifi.sh -s 4 -t 4 -r "$prim" -q "$FQ" -o "$outfile" -x "$tmpfile" 
if [[ $? -eq 0 ]]; then
rm "$FQ"
else
exit 1
fi
