#!/bin/bash
#SBATCH -p himem2
#SBATCH -q himem
#SBATCH -c 36
#SBATCH --mem=1200G
#SBATCH -J 3DDNA_JBAT
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

set -e
date
echo "[M]: Host Name: `hostname`"
module load gnu-parallel/20160622

home=/home/FCAM/msmith
core=/core/projects/EBP/smith
scratch=/scratch/msmith
prim=${core}/CBP_assemblyfiles/interior_primary_final.fa
asm_file="${prim%.*}.assembly"
merge_nodups=${scratch}/juicer_formanualcur/work/intdf137/aligned/merged_nodups.txt

export PATH="${core}/bin/3d-dna:$PATH"
export TMPDIR=/scratch/msmith

#awk -f ${core}/bin/3d-dna/utils/generate-assembly-file-from-fasta.awk "$prim" > "$asm_file"

#no output file specified, so run in scratch to control where output
cd ${scratch}
${core}/bin/3d-dna/visualize/run-assembly-visualizer.sh "$asm_file" "$merge_nodups"
