#!/bin/bash
#SBATCH -J eviann_test
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 10
#SBATCH --mem=48G
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

set -e
date
echo "[M]: Host Name: `hostname`"

home=/home/FCAM/msmith
core=/core/projects/EBP/msmith
genome=${core}/manual_curation_files/interior_primary_mancur_masked_500kb.fa
workdir=${core}/genome_annotation_isoseq_data/test
transcript_file=${workdir}/test_eviann_evidence.txt
protein_db=${workdir}/conifer_proteins_test.faa

cd $workdir

export PATH="${core}/bin/EviAnn-2.0.4/bin:$PATH"
module load minimap2/2.28 hisat2/2.2.1 samtools/1.19
#all other dependencies are within the Eviann package itself

eviann.sh -t 10 -g ${genome} -r ${transcript_file} -p ${protein_db} -m 100000
