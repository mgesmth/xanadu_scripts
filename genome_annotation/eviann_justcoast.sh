#!/bin/bash
#SBATCH -J eviann_coastal
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 36
#SBATCH --mem=200G
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

set -e
date
echo "[M]: Host Name: `hostname`"

home=/home/FCAM/msmith
core=/core/projects/EBP/smith
coa_genome=${core}/coastal/coastal_masked_500kb.fa
transcript_file=${home}/transcriptome/03_eviann_annotation/evidence_coastal.txt
protein_db=${home}/transcriptome/02_braker_annotation/conifer_geneSet_protein_v2_150.faa
workdir=${core}/eviann/eviann_justcoa

export PATH="${core}/bin/EviAnn-2.0.4/bin:$PATH"
module load minimap2/2.28 hisat2/2.2.1 samtools/1.19
#all other dependencies are within the Eviann package itself

if [[ ! -d ${workdir} ]] ; then
  mkdir ${workdir}
fi

cd ${workdir}

eviann.sh -t 36 -g ${coa_genome} -r ${transcript_file} -p ${protein_db} -m 100000
