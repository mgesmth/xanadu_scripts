#!/bin/bash
#SBATCH -J busco_embryo
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 12
#SBATCH --mem=120G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=meg8130@student.ubc.ca
#SBATCH -o busco_embryo.%j.out
#SBATCH -e busco_embryo.%j.err

echo `hostname`

module load python/3.8.1
module load biopython/1.70
module load bbmap/39.08
module load blast/2.7.1
module load augustus/3.6.0 
module load hmmer/3.3.2
module load R/4.2.2
export PATH="/home/FCAM/msmith/R/x86_64-pc-linux-gnu-library/4.2:$PATH"
module load busco/5.4.5
export PATH="/home/FCAM/msmith/scripts:$PATH"

core=/core/projects/EBP/smith
prim=${core}/CBP_assemblyfiles/interior_primary_final.fa
alt=${core}/CBP_assemblyfiles/interior_alternate_final.fa
mine=${core}/scaffold/withpairtools_noerrorcorrect/intDF011_scaffolds_final.fa
coastal=${core}/coastal/coastalDF_scaffrenamed_sorted.fa
mode="genome"
db="embryophyta_odb12"
out=${core}/busco/intDF011

run_busco.sh -t 12 -i ${mine} -m "${genome}" -l "${db}" -o "${out}"
