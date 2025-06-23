#!/bin/bash
#SBATCH -J gfatools_view
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 8
#SBATCH --mem=56G
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

echo `hostname`

home=/home/FCAM/msmith
core=/core/projects/EBP/smith
scratch=/scratch/msmith
minidir=${home}/svs/minigraph_out
miscdir=${home}/svs/misc

export PATH="${core}/bin/gfatools:$PATH"
set -e
cd ${miscdir}

gfatools view -l @segmentlist_forgfatools.txt "${minidir}/all_brokenscaffolds.gfa" > "${scratch}/SV_tmp.gfa"
gfatools gfa2fa "${scratch}/SV_tmp.gfa" > "${miscdir}/segment_sequences.fa"
#rm "${scratch}/SV_tmp.gfa"
