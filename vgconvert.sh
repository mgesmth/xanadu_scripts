#!/bin/bash
#SBATCH -J vgconvert
#SBATCH -p himem
#SBATCH -q himem
#SBATCH -c 12
#SBATCH --mem=100G
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
vg convert -t 12 -W -g "${minidir}/all_brokenscaffolds.gfa" -f > "${minidir}/all_brokenscaffolds1.0.gfa"

singularity exec ${core}/bin/odgi_0.9.2.sif \
odgi build -t 12 -Os -g "${minidir}/all_brokenscaffolds1.0.gfa" -o "${home}/odgi/all_brokenscaffolds.og"

