#!/bin/bash
#SBATCH -J repeatMasker
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 6
#SBATCH --mem=30G
#SBATCH --array=[0-209]
#SBATCH -o %x.%a.%A.out
#SBATCH -e %x.%a.%A.err

echo "[M]: Host Name: `hostname`"

home=/home/FCAM/msmith
core=/core/projects/EBP/smith
scratch=/scratch/msmith
repdir=${home}/repeats_alternate/above_1Mb
db=${home}/repeats_alternate/primary_db
tetools=${core}/bin/dfam-tetools-latest.sif

cd ${repdir}

files=($(cat above.txt))
file=${files[$SLURM_ARRAY_TASK_ID]}

singularity exec $tetools \
RepeatMasker -frag 10000000 -pa 6 -gff -q -dir ${repdir} -lib "${db}/primary-families.fa" "${file}"
