#!/bin/bash

#SBATCH -J 00a.prep_genome
#SBATCH -o 98_log_files/%x_%j.out
#SBATCH -e 98_log_files/%x_%j.err
#SBATCH -c 10
#SBATCH --mem=36G

GENOMEFOLDER="03_genome"
GENOME=$(ls -1 $GENOMEFOLDER/*{fasta,fa,fasta.gz,fa.gz} | xargs -n 1 basename)

cd ${GENOMEFOLDER}

if [[ ! -f "${GENOME}.fai" ]] ; then
  echo ">> No FAI detected. Generating ... <<"
  module load samtools
  samtools index $GENOME
  echo ">> Done FAI <<"
else
  echo ">> FAI Detected. <<"
fi

if [[ ! -f "${GENOME}.bwt" ]] ; then
  echo ">> No BWA index detected. Generating ... <<"
  module load bwa
  bwa index $GENOME
  echo ">> Done BWA <<"
else
  echo ">> BWA index detected. <<"
fi

if [[ ! -f "${GENOME}.dict" ]] ; then
  module load picard
  echo ">> No Sequence Dictionary detected. Generating... <<"
  java -jar $PICARD CreateSequenceDictionary \
  I=${GENOME} \
  O="${GENOME}.dict"
  echo ">> Done. <<"
else
  echo ">> Sequence Dictionary detected. <<"
fi 
