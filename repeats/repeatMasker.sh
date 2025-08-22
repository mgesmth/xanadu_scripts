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
prim=interior_primary_final.fa
tetools=${core}/bin/dfam-tetools-latest.sif

#I guess RepeatMasker needs the genome to be in the workingdir?
cp ${core}/CBP_assemblyfiles/${prim} ${scratch}
cd ${scratch}

#Putting quick search option because it's taking way too fucking long on the default
singularity exec $tetools \
RepeatMasker -frag 60000000 -pa 24 -gff -q -html -dir ${repdir} -lib "${db}/primary-families.fa" "./${prim}"
