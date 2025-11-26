#!/bin/bash
#SBATCH -J repeatMasker
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 12
#SBATCH --mem=60G
#SBATCH --array=[0-19]
#SBATCH -o %x.%a.%j.out
#SBATCH -e %x.%a.%j.err

echo "[M]: Host Name: `hostname`"

home=/home/FCAM/msmith
core=/core/projects/EBP/smith
scratch=/scratch/msmith
repdir=${home}/repeats_alternate/first_20
db=${home}/repeats_alternate/primary_db
tetools=${core}/bin/dfam-tetools-latest.sif

cd ${repdir}

files=($(cat first_20.txt))
file=${files[$SLURM_ARRAY_TASK_ID]}

singularity exec $tetools \
RepeatMasker -frag 10000000 -pa 12 -gff -q -dir ${repdir} -lib "${db}/primary-families.fa" "${file}"
