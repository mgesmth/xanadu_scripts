#!/bin/bash
#SBATCH -J minigraph_graphgen
#SBATCH -p himem2
#SBATCH -q himem
#SBATCH -c 36
#SBATCH --mem=1000G
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

date
set -e
echo "[M]: Host Name: `hostname`"
echo "[M]: Beginning minigraph graph generation"

home=/home/FCAM/msmith
core=/core/projects/EBP/smith
scratch=/scratch/msmith
prim=${scratch}/interior_primary_final_mancur_bigscaffoldsplit.fa
alt=${scratch}/interior_alternate_1Mb.fa
coast=${scratch}/coastal_1Mb.fa
prx="final_finalpangenome"
outdir=${core}/manual_curation_files/minigraph
threads="$(getconf _NPROCESSORS_ONLN)"
prx="final_finalpangenome"
outdir=${core}/manual_curation_files/minigraph

#executables
module load zlib/1.2.11
export PATH="${core}/bin/minigraph-0.21:$PATH"
export PATH="${core}/bin/gfatools:$PATH"

#pangenome graph:
minigraph -cxggs -t 24 ${prim} ${alt} ${coast} > "${outdir}/${prx}.gfa"
#call bubbles (SVs)
gfatools bubble "${outdir}/${prx}.gfa" > "${outdir}/${prx}_unfiltered.bed"
#get stats on the pangenome graph (number of nodes/edges, etc.)
gfatools stat "${outdir}/${prx}.gfa" > "${outdir}/${prx}.stat"

if [[ $? -eq 0 ]] ; then
echo "[M]: Done."
exit 0
else
echo "[E]: Graph generation failed. Exit code $?"
fi
