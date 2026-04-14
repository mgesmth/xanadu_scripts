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
int_genome=${home}/repeats_round2/concatenated_results/interior_primary_mancur_masked.fa
transcript_file=${home}/genome_annotation/03_eviann_annotation/evidence_allv.txt
protein_db=${home}/genome_annotation/02_braker_annotation/conifer_geneSet_protein_v2_150.faa
int_workdir=${core}/eviann/eviann_int_allvdata_new

export PATH="${core}/bin/EviAnn-2.0.4/bin:$PATH"
module load minimap2/2.28 hisat2/2.2.1 samtools/1.19
#all other dependencies are within the Eviann package itself

int_genome_500kb="${int_genome%.fa}_500kb.fa"

#cd ${home}/repeats_round2/concatenated_results
#samtools faidx ${int_genome}
#first_below500k=$(awk '$2 >= 500000 { next } {print $1 ; exit}' ${int_genome}.fai)
#linenum=$(($(grep -n -w ">${first_below500k}" ${int_genome} | cut -f 1 -d ":")-1))
#head -n ${linenum} ${int_genome} > ${int_genome_500kb}

if [[ ! -d ${int_workdir} ]] ; then
  mkdir ${int_workdir}
fi

cd ${int_workdir}

#primary
eviann.sh -t 36 -g ${int_genome_500kb} -r ${transcript_file} -p ${protein_db} -m 100000
