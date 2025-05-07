#!/bin/bash
#SBATCH -J gfatools_stat
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 8
#SBATCH --mem=100G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=meg8130@student.ubc.ca
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

echo "[M]: Host Name: `hostname`"

minidir=/home/FCAM/msmith/minigraph_out
in_gfa=${minidir}/all_brokenscaffolds.gfa
out=${minidir}/all_brokenscaffolds.stat

export PATH="/core/projects/EBP/smith/bin/gfatools:$PATH"

gfatools stat "${in_gfa}" > "${out}"
