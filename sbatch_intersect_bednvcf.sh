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
vcf=${mini}/all_dougfir_allthree_altall.sv.vcf
bed=${mini}/all_brokenscaffolds.bed 
min="0.00000005"
out=${home}/svs/intersect/bed2vcf

module load bedtools/2.29.0

${scripts}/bedtools_intersect.sh -a ${bed} -b ${vcf} -f ${min} -F ${min} -o ${out}

