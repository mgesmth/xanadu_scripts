#!/bin/bash
#SBATCH -J repeatMasker
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 24
#SBATCH --mem=100G
#SBATCH --array=[0-2]
#SBATCH -o %x.%A.%a.out
#SBATCH -e %x.%A.%a.err

echo "[M]: Host Name: `hostname`"

home=/home/FCAM/msmith
core=/core/projects/EBP/smith
scratch=/scratch/msmith
repdir=${home}/repeats_coastal/first_42
db=${home}/repeats_coastal/primary_db
tetools=${core}/bin/dfam-tetools-latest.sif

cd ${repdir}

files=($(cat redo_files_2.txt))
file=${files[$SLURM_ARRAY_TASK_ID]}

singularity exec $tetools \
RepeatMasker -frag 100000000 -pa 24 -q -dir ${repdir} -lib "${db}/primary-families.fa" "${file}"
