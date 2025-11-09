#!/bin/bash
#SBATCH -J repeatMasker
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 6
#SBATCH --mem=60G
#SBATCH --array=[0-24]
#SBATCH -o %x.%A.%a.out
#SBATCH -e %x.%A.%a.err

echo "[M]: Host Name: `hostname`"

home=/home/FCAM/msmith
core=/core/projects/EBP/smith
scratch=/scratch/msmith
repdir=${home}/repeats_coastal/first_42
db=${home}/repeats_coastal/primary_db
tetools=${core}/bin/dfam-tetools-latest.sif

# for all scaffolds above 100Mb

cd ${repdir}

files=($(cat redo_files.txt))
file=${files[$SLURM_ARRAY_TASK_ID]}

singularity exec $tetools \
RepeatMasker -frag 60000000 -pa 6 -q -dir ${repdir} -lib "${db}/primary-families.fa" "${file}"
