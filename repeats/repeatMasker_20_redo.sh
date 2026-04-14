#!/bin/bash
#SBATCH -J repeatMasker_redo
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 12
#SBATCH --mem=36G
#SBATCH -o %x.%a.%j.out
#SBATCH -e %x.%a.%j.err

echo "[M]: Host Name: `hostname`"

home=/home/FCAM/msmith
core=/core/projects/EBP/smith
scratch=/scratch/msmith
repdir=first_20
db=${home}/repeats_round2/primary_db
tetools=${core}/bin/dfam-tetools-latest.sif

cd ${repdir}

file=interior_primary_mancur_scaffold_002.fa

singularity exec $tetools \
RepeatMasker -frag 1000000 -pa 12 -gff -q -dir . -lib "${db}/primary-families.fa" "${file}"
