#!/bin/bash
#SBATCH -J repeatMasker
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
scratch=/scratch/msmith
repdir=${home}/repeats
db=${repdir}/primary_db
prim=${core}/CBP_assemblyfiles/interior_primary_final.fa
tetools=${core}/bin/dfam-tetools-latest.sif

cd $repdir

singularity shell $tetools
RepeatMasker -pa 24 -gff -html -dir ${repdir} -lib "${db}/primary-families.fa" "$prim"
