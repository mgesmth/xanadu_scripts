#!/bin/bash
#SBATCH -J 3DDNA
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 36
#SBATCH --mem=500G
#SBATCH --mail-user=meg8130@student.ubc.ca
#SBATCH --mail-type=END,FAIL
#SBATCH -o /core/projects/EBP/smith/manual_curation_log/%x.%j.out
#SBATCH -e /core/projects/EBP/smith/manual_curation_log/%x.%j.err

set -e
date
echo "[M]: Host Name: `hostname`"
home=/home/FCAM/msmith
core=/core/projects/EBP/smith
scratch=/scratch/msmith
outdir=${core}/3DDNA
merge_nodups=${scratch}/juicer_formanualcur/work/intdf137/aligned/merged_nodups.txt
prim=${core}/CBP_assemblyfiles/interior_primary_final.fa

export PATH="${core}/bin/3d-dna:$PATH"
module load gnu-parallel/20160622
module load java/22
export TMPDIR=/scratch/msmith

#I just want the map that I can use to run JBAT with (-e, -r0)
#Note: I modified 3DDNA visualizer scripts to accomodate a tmpdir in the juicertools pre command
cd ${outdir}
#run-asm-pipeline.sh -e --rounds 0 "$prim" "$merge_nodups"
#visualize module failed bc of GNU parallel. Rerunning visualization step without it
${core}/bin/3d-dna/visualize/run-asm-visualizer.sh -p true -q 1 -i -c interior_primary_final.0.cprops interior_primary_final.0.asm interior_primary_final.mnd.txt 

