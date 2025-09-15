#!/bin/bash
#SBATCH -J GMAP
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 24
#SBATCH --mem=250G
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

set -e
date
echo "[M]: Host Name: `hostname`"

home=/home/FCAM/msmith
core=/core/projects/EBP
scratch=/scratch/msmith
mancur=${core}/manual_curation_files
asm=${mancur}/interior_primary_final_mancur2.fa
outdir=${home}/transcriptome/01_transcriptome_alignment/GMAP
gfacs=${home}/transcriptome/01_transcriptome_alignment/gFACs/filtered
if [[ ! -d ${gfacs} ]] ; then
  mkdir ${gfacs}
fi
gmap=${home}/transcriptome/01_transcriptome_alignment/GMAP

module load gFACs/1.1.2
gfacs_script=/isg/shared/apps/gFACs/1.1.2/gFACs.pl

perl ${gfacs_script} \
-f gmap_2017_03_17_gff3 \
--statistics \
--unique-genes-only \
--min-CDS-size 300 \
--rem-genes-without-start-and-stop-codon \
--get-fasta \
--get-protein-fasta \
--allowed-inframe-stop-codons 0 \
--min-exon-size 9 \
--min-intron-size 9 \
--create-gtf --create-gff3 \
-p "intdf137_filtered" \
--fasta ${asm} \
-O ${gfacs} \
${gmap}/intdf137_gmap_genomeannotation_00.gff3
