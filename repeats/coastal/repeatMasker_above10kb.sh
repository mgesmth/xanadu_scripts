#!/bin/bash
#SBATCH -J repeatMasker
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 3
#SBATCH --mem=8G
#SBATCH --array=[0-389]
#SBATCH -o %x.%a.%A.out
#SBATCH -e %x.%a.%A.err

echo "[M]: Host Name: `hostname`"

home=/home/FCAM/msmith
core=/core/projects/EBP/smith
scratch=/scratch/msmith
repdir=${home}/repeats_coastal/above_10kb
db=${home}/repeats/primary_db
tetools=${core}/bin/dfam-tetools-latest.sif

cd ${repdir}

files=($(cat above10kb.txt))
file=${files[$SLURM_ARRAY_TASK_ID]}

singularity exec $tetools \
RepeatMasker -pa 3 -q -dir ${repdir} -lib "${db}/primary-families.fa" "${file}"
if [[ -f ${file}.cat.out ]] ; then
  touch ${file}.tbl
  echo "fabricated tbl file for repeat-less contig" >> ${file}.tbl
  echo "file name: ${file}" >> ${file}.tbl
  echo "sequences: 1" >> ${file}.tbl
  scaff_num=$(echo ${file/.fa/} | sed 's/coastal_scaffold//g')
  length=$(grep "scaffold_${scaff_num}_coastal" ${core}/coastal/below1Mb_above10kb.fa.fai | cut -f2)
  echo "total length: ${length} bp" >> ${file}.tbl
  echo "bases masked: 0 bp" >> ${file}}.tbl
fi 
