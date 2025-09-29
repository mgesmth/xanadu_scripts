#!/bin/bash
#SBATCH -J gFACs
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 12
#SBATCH --mem=64G
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=meg8130@student.ubc.ca
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

#Extract unfiltered transcriptome alignment - allows you to get a picture of where you're starting from for quality control
#Fourth step in genome annotation
#Adapted from https://gitlab.com/PlantGenomicsLab/genome-annotation-of-douglas-fir/-/blob/master/0_Transcriptome_Alignment/scripts/unfiltered_gfacs.sh?ref_type=heads

set -e
date
echo "[M]: Host Name: `hostname`"

home=/home/FCAM/msmith
core=/core/projects/EBP/smith
outdir=${home}/transcriptome/01_transcriptome_alignment/gFACs/unfiltered
gmap=${home}/transcriptome/01_transcriptome_alignment/GMAP
gfacs=${home}/transcriptome/01_transcriptome_alignment/gFACs/unfiltered
if [[ ! -d ${gfacs} ]] ; then
  mkdir ${gfacs}
fi
asm=${core}/manual_curation_files/interior_primary_mancur_masked.fa

module load gFACs/1.1.2
gfacs_script=/isg/shared/apps/gFACs/1.1.2/gFACs.pl

#note: the -f command is for format - this tells gfacs how to parse the file

perl ${gfacs_script} -f gmap_2017_03_17_gff3 --statistics -p "intdf137_unfiltered" \
--get-fasta-without-introns --get-protein-fasta --create-gtf --create-gff3 \
--fasta ${asm} \
-O ${gfacs}/ \
${gmap}/intdf137_gmap_genomeannotation_00.gff3
