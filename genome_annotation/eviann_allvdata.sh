#!/bin/bash
#SBATCH -J eviann
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
int_genome=${core}/manual_curation_files/interior_primary_mancur_masked_500kb.fa
coa_genome=${core}/coastal/coastal_masked_500kb.fa
transcript_file=${home}/transcriptome/03_eviann_annotation/evidence_allv.txt
protein_db=${home}/transcriptome/02_braker_annotation/conifer_geneSet_protein_v2_150.faa
int_workdir=${core}/eviann/eviann_int_allvdata
coa_workdir=${core}/eviann/eviann_coa_allvdata

export PATH="${core}/bin/EviAnn-2.0.4/bin:$PATH"
module load minimap2/2.28 hisat2/2.2.1 samtools/1.19
#all other dependencies are within the Eviann package itself

cd ${int_workdir}

#interior
eviann.sh -t 36 -g ${int_genome} -r ${transcript_file} -p ${protein_db} -m 100000

cd ${coa_workdir}

#coastal 
eviann.sh -t 36 -g ${coa_genome} -r ${transcript_file} -p ${protein_db} -m 100000
