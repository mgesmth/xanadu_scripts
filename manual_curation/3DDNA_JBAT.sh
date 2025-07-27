#!/bin/bash
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 24
#SBATCH --mem=500G
#SBATCH -J 3DDNA_JBAT
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

set -e
date
echo "[M]: Host Name: `hostname`"

home=/home/FCAM/msmith
core=/core/projects/EBP/smith
scratch=/scratch/msmith
prim=${core}/CBP_assemblyfiles/interior_primary_final.fa
asm_file="${prim%.*}.assembly"
merge_nodups=${scratch}/juicer_formanualcur/work/intdf137/aligned/merged_nodups.txt

export PATH="${core}/bin/3d_dna:$PATH"

awk –f ${core}/bin/3d_dna/utils/generate-assembly-file-from-fasta.awk "$prim" > "$asm_file"
#no output file specified, so run in scratch to control where output
cd ${scratch}
${core}/bin/3d_dna/visualize/run-assembly-visualizer.sh "$asm_file" "$merge_nodups"
