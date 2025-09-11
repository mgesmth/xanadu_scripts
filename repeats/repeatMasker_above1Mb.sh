#!/bin/bash
#SBATCH -J repeatMasker
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 4
#SBATCH --mem=30G
#SBATCH --array=[0-177]%10
#SBATCH -o %x.%a.%A.out
#SBATCH -e %x.%a.%A.err

echo "[M]: Host Name: `hostname`"

home=/home/FCAM/msmith
core=/core/projects/EBP/smith
scratch=/scratch/msmith
repdir=${home}/repeats_mancur/above_1Mb
db=${home}/repeats/primary_db
tetools=${core}/bin/dfam-tetools-latest.sif

cd ${repdir}

files=($(cat above_files.txt))
file=${files[$SLURM_ARRAY_TASK_ID]}

singularity exec $tetools \
RepeatMasker -frag 60000000 -pa 6 -gff -q -dir ${repdir} -lib "${db}/primary-families.fa" "${file}"
