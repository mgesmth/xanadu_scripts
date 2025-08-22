#!/bin/bash
#SBATCH -J repeatMasker
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 6
#SBATCH --mem=10G
#SBATCH --array=[0-2996]%300
#SBATCH --mail-type=ALL
#SBATCH --mail-user=meg8130@student.ubc.ca
#SBATCH -o %x.%a.%j.out
#SBATCH -e %x.%a.%j.err

echo "[M]: Host Name: `hostname`"

home=/home/FCAM/msmith
core=/core/projects/EBP/smith
scratch=/scratch/msmith
repdir=${home}/repeats
db=${repdir}/primary_db
prim=interior_primary_final.fa
tetools=${core}/bin/dfam-tetools-latest.sif

#I guess RepeatMasker needs the genome to be in the workingdir?
cd ${scratch}/repeatMasker_rest

files=($(ls -1 ${scratch}/repeatMasker_rest/interior*))
file=${files[$SLURM_ARRAY_TASK_ID]}

#Putting quick search option because it's taking way too fucking long on the default
singularity exec $tetools \
RepeatMasker -frag 60000000 -pa 6 -gff -q -html -dir ${repdir} -lib "${db}/primary-families.fa" "${file}"
