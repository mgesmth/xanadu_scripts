#!/bin/bash
#SBATCH -J intersect
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 12
#SBATCH --mem=36G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=meg8130@student.ubc.ca
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

home=/home/FCAM/msmith
scripts=${home}/scripts
mini=${home}/svs/minigraph_out
inter=${home}/svs/intersect
vcf=${mini}/all_dougfir_scaffcoord.sv.vcf
gff=${inter}/liftoff_interior_douglas_fir_copies_flank05.gff
min="0.00000005"
out=${home}/svs/intersect/bed2vcf

export PATH="/core/projects/EBP/smith/bin:$PATH"

bedtools intersect -a "$gff" -b "$vcf" -f "$min" -F "$min" -wo > "$out"
