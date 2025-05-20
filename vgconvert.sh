#!/bin/bash
#SBATCH -J vgconvert
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 24
#SBATCH --mem=500G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=meg8130@student.ubc.ca
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

echo "[M]: Host Name: `hostname`"

home=/home/FCAM/msmith
core=/core/projects/EBP/smith
export PATH="${core}/bin:$PATH"
minidir=${home}/minigraph_out

#rGFA to GFA1.1 (hopefully)
#vg convert -t 24 -gfW "${minidir}/all_brokenscaffolds.gfa" > "${minidir}/all_brokenscaffolds1.0.gfa"

singularity exec ${core}/bin/odgi_0.9.2.sif \
odgi build -t 24 -Os -g "${minidir}/all_brokenscaffolds1.0.gfa" -o "${home}/odgi/all_brokenscaffolds.og"

