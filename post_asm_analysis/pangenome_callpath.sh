#!/bin/bash
#SBATCH -J minigraph_callpath
#SBATCH -p himem2
#SBATCH -q himem
#SBATCH -c 24
#SBATCH --mem=1000G
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

set -e
date
echo "[M]: Host Name: `hostname`"

home=/home/FCAM/msmith
core=/core/projects/EBP/smith
scratch=/scratch/msmith
prx="final_finalpangenome"
outdir=${core}/manual_curation_files/minigraph
asm=$1
outfix=$2
gfa="${outdir}/${prx}.gfa"
threads="$(getconf _NPROCESSORS_ONLN)"

#executables
module load zlib/1.2.11
export PATH="${core}/bin/minigraph-0.21:$PATH"
export PATH="${core}/bin/gfatools:$PATH"

#call path
minigraph -cxasm --call -t "$threads" "${outdir}/${prx}.gfa" $asm > "${outdir}/${outfix}.bed"

if [[ $? -eq 0 ]] ; then
echo "[M]: Done."
exit 0
else
echo "[E]: Call path failed. Exit code $?"
fi


