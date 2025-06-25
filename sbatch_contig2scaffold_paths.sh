#!/bin/bash
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 6
#SBATCH --mem=25G
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

echo `hostname`

home=/home/FCAM/msmith
minidir=${home}/svs/minigraph_out
INDEX=${minidir}/contig2scaffoldpos.idx
alt_file=${minidir}/alternate_path_verified.bed
alt_out=${minidir}/alternate_path_scaff_verified.bed
coa_file=${minidir}/coastal_path_verified.bed
coa_out=${minidir}/coastal_path_scaff_verified.bed

${home}/scripts/contig2scaffold_general.sh -p "$INDEX" -i "$alt_file" -o "$alt_out" -f "path_bed"
${home}/scripts/contig2scaffold_general.sh -p "$INDEX" -i "$coa_file" -o "$coa_out" -f "path_bed"
