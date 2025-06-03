#!/bin/bash
#SBATCH -J gff3_2_fasta
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 8
#SBATCH --mem=25G
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

echo "[M]: Host name: `hostname`"

home=/home/FCAM/msmith
core=/core/projects/EBP/smith
source ${core}/bin/gff3toolkit_venv/bin/activate
gff3=${home}/svs/intersect/completecovered_genes_fixed.gff3
fa=/scratch/msmith/interior_primary_final.fa
out="${home}/intersect/completecovered_genes"

base=$(basename ${gff3})
echo "[M]: Beginning gff3 to fasta conversion of ${base}. Sending to ${out}."
gff3_to_fasta -g ${gff3} -f ${fa} -st all -d simple -o "$out"
