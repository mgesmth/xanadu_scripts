#!/bin/bash
#SBATCH -J GMAP
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 24
#SBATCH --mem=250G
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

#Align clustered transcripts to new genome
#Third step in genome annotation
#Adapted from https://gitlab.com/PlantGenomicsLab/genome-annotation-of-douglas-fir/-/blob/master/0_Transcriptome_Alignment/scripts/gmap.sh?ref_type=heads

set -e
date
echo "[M]: Host Name: `hostname`"

module load samtools/1.19
module load gmap/2017-03-17

home=/home/FCAM/msmith
core=/core/projects/EBP/smith
scratch=/scratch/msmith
mancur=${core}/manual_curation_files
asm=${mancur}/interior_primary_final_mancur2.fa
outdir=${home}/transcriptome/01_transcriptome_alignment/GMAP

#Small minor scaffolds are most likely to be repetitive and tf not euchromatic
#Filtering out scaffolds smaller than 500kb
#saving to a dummy file for speed in next step

cd ${mancur}
echo "[M]: Finding correct line number in asm."
awk '
#process index - get the scaffold after the last scaffold that is 500kb or bigger (we need to cut off the asm a line above that header)
FNR==NR {
  if ($2 > 500000) {
    prev=1
  } else if ($2 < 500000 && prev == 1) {
    prev=0
    next_scaffold=$1
  } else if ($2 < 500000 && prev == 0) {
    next
  }
}
#process asm - print the line number corresponding to the end of the last 500kb scaffold
FNR!=NR {
  if ($0 ~ next_scaffold) {
    print FNR-1
    exit
  } else {
    next
  }
}' "${asm}.fai" ${asm} > line_number.tmp
echo "[M]: Done."

line_num=$(tr -d '\n' < line_number.tmp)
echo "[M]: Creating 500kb assembly."
head -n ${line_num} "$asm" > interior_primary_mancur_500kb.fa

echo "[M]: Getting scaffold names"
#Get preferred scaffold names for gmap index build
samtools faidx interior_primary_mancur_500kb.fa
cut -f1 interior_primary_mancur_500kb.fa.fai > ${outdir}/old_scaffold_names.txt
cut -f1 interior_primary_mancur_500kb.fa.fai | sed 's/HiC_//g' > ${outdir}/new_scaffold_names.txt
paste ${outdir}/old_scaffold_names.txt ${outdir}/new_scaffold_names.txt > ${outdir}/scaffolds.txt && \
rm ${outdir}/new_scaffold_names.txt ${outdir}/old_scaffold_names.txt
#reset asm
asm=${mancur}/interior_primary_mancur_500kb.fa
rm line_number.tmp

#to build index, must have scaffolds in individual fasta files
#module load seqkit/2.10.0
#seqkit split -s 1 "$asm" -O ${outdir}/split_fa
#module unload seqkit/2.10.0

echo "[M]: Starting with GMAP"
#Okay start with GMAP
export PATH="${core}/bin/gmap-gmap_2017_03_17/bin:$PATH"
transcripts=${home}/transcriptome/01_transcriptome_alignment/centroids_clustered.fasta
#Build DB
#cd ${outdir}/split_fa
gmap_build -D ${outdir}/db -E -d "intdf137" -n ${outdir}/scaffolds.txt -s names ${asm}
#this command is taken from here https://gitlab.com/PlantGenomicsLab/genome-annotation-of-douglas-fir/-/blob/master/0_Transcriptome_Alignment/scripts/gmap.sh
#the original transcriptome paper
cd ${outdir}
gmapl -K 1000000 -L 10000000 --cross-species -F -D ${outdir}/db -d "intdf137" \
-f gff3_gene --min-trimmed-coverage=0.95 --min-identity=0.95 -n1 -T \
"$transcripts" > intdf137_gmap_genomeannotation_00.gff3
