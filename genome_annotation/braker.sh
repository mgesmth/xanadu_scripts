#!/bin/bash
#SBATCH -J braker
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 36
#SBATCH --mem=300G
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

set -e
date
echo "[M]: Host Name: `hostname`"

home=/home/FCAM/msmith
core=/core/projects/EBP/smith
asm=${core}/manual_curation_files/interior_primary_mancur_masked_500kb.fa
alndir=${core}/genome_annotation_shortread_data/alignments
se_hints=${alndir}/single_end_hints.gff
pe_hints=${alndir}/paired_end_hints.gff
conifer_db=${home}/transcriptome/02_braker_annotation/conifer_geneSet_protein_v2_150.faa


module load python/3.10.1 biopython/1.70 perl/5.36.0 bamtools/2.5.1 blast/2.13.0 genomethreader/1.7.3

braker.pl --species=int_Doug_fir --genome=${asm} \
--bam
