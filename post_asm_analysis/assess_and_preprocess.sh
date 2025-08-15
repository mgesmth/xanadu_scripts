#!/bin/bash
#SBATCH -J postmancur_launch
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 1
#SBATCH --mem=2G
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

set -e

echo "[M]: Host Name: `hostname`"

#modules
module load quast/5.2.0
module load busco/
module load

#variables
home=/home/FCAM/msmith
core=/core/projects/EBP/smith
scratch=/scratch/msmith
minidir=${home}/svs/minigraph_out
prim=${core}/manual_curation_files/interior_primary_final_mancur.fa
alt=${core}/CBP_assemblyfiles/interior_alternate_final.fa
coast=${core}/coastal/coastalDF_scaffrenamed_sorted.fa
out_prefix="final_finalpangenome"
threads="36"
gfa="${minidir}/${out_prefix}.gfa"

#### Minigraph ----

date
echo "[M]: Beginning pangenome construction."
minigraph -cxggs -t "$threads" "$prim" "$alt" "$coast" > "$gfa"

