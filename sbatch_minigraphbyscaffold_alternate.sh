#!/bin/bash
#SBATCH -J minigraph_byscaffold
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 4
#SBATCH --mem=75G
#SBATCH -p general
#SBATCH -q general
#SBATCH --array=[0-32]%4
#SBATCH -o %x_%A.%a.out
#SBATCH -e %x_%A.%a.err

home=/home/FCAM/msmith
core=/core/projects/EBP/smith
scratch=/scratch/msmith
altdir=${scratch}/minigraph_prep/alternate_fastas
primdir=${scratch}/minigraph_prep/primary_fastas
outdir=${scratch}/minigraph_prep/primalt_out
threads="4"

module load zlib/1.2.11
export PATH="${core}/bin/minigraph-0.21:$PATH"
export PATH="${core}/bin/gfatools:$PATH"

echo "[M]: Host Name:" `hostname`
echo "[M]: This is minigraph task $SLURM_ARRAY_TASK_ID"

#Create an array containing the names of the PRIM fasta files to align
FILESPRIM=($(ls -1 ${primdir} | sort -g -t '_' -k2))
#Create an array containing the names of the ALT fasta files to align (in order of 1 to n)
FILESALT=($(ls -1 ${altdir} | sort -g -t '_' -k2))

# Sanity check: ensure array index is in range
if [ "$SLURM_ARRAY_TASK_ID" -ge "${#FILESPRIM[@]}" ]; then
  echo "[E]: SLURM_ARRAY_TASK_ID ($SLURM_ARRAY_TASK_ID) out of bounds (max index: $((${#FILESPRIM[@]} - 1)))"
  exit 1
fi

# Extract the specific file names for this task
FA_REF="${FILESPRIM[$SLURM_ARRAY_TASK_ID]}"
FA_QRY="${FILESALT[$SLURM_ARRAY_TASK_ID]}"

# Get clean base name (no extension) for output naming
FA_REF_BASENAME=$(basename "$FA_REF" .fasta)
OUT="${outdir}/${FA_REF_BASENAME}_alternate"

${home}/scripts/minigraph_gfatoolsbbl.sh -t "$threads" -r "${primdir}/${FA_REF}" -q "${altdir}/${FA_QRY}" -o "$OUT"
