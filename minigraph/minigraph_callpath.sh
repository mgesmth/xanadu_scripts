#!/bin/bash
#SBATCH -J minigraph_call
#SBATCH -p himem2
#SBATCH -q himem
#SBATCH -c 24
#SBATCH --mem=200G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=meg8130@student.ubc.ca
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

echo `hostname`

home=/home/FCAM/msmith
core=/core/projects/EBP/smith
scratch=/scratch/msmith

module load zlib/1.2.11
export PATH="${core}/bin/minigraph-0.21:$PATH"
export PATH="${core}/bin/gfatools:$PATH"

minidir=/home/FCAM/msmith/minigraph_out
gfa=${minidir}/all_brokenscaffolds.gfa
coastal=${scratch}/coastal_1Mb_broken.fa
alternate=${scratch}/interior_alternate_1Mb_broken.fa 
primary=${scratch}/interior_primary_1Mb_broken.fa

minigraph -cxasm --call -t24 "$gfa" "$coastal" > "${minidir}/coastal_path.bed"
#minigraph -cxasm --call -t24 "$gfa" "$alternate" > "${minidir}/alternate_path.bed"
#minigraph -cxasm --call -t24 "$gfa" "$primary" > "${minidir}/primary_path.bed"
