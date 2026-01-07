#!/bin/bash
#SBATCH -J merge_nodups
#SBATCH -p himem2
#SBATCH -q himem
#SBATCH -c 36
#SBATCH --mem=1000G
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

echo `hostname`
set -e

module load samtools/1.20 java-sdk/1.8.0_92
home=/home/FCAM/msmith
core=/core/projects/EBP/smith
scratch=/scratch/msmith
sandbox=/sandbox/msmith
gid="intdf137"
site="Arima"
juiceDir=${sandbox}/juicer_formanualcur
topDir=${juiceDir}/work/intdf137
outputdir=${topDir}/aligned
splitdir=${topDir}/splits
site_file=${juiceDir}/restriction_sites/intdf137_Arima.txt
ligation="'(GAATAATC|GAATACTC|GAATAGTC|GAATATTC|GAATGATC|GACTAATC|GACTACTC|GACTAGTC|GACTATTC|GACTGATC|GAGTAATC|GAGTACTC|GAGTAGTC|GAGTATTC|GAGTGATC|GATCAATC|GATCACTC|GATCAGTC|GATCATTC|GATCGATC|GATTAATC|GATTACTC|GATTAGTC|GATTATTC|GATTGATC)'"
export TMPDIR=${core}

cd ${outputdir}

samtools view -@ 24 -O SAM -F 1024 $outputdir/merged_dedup.bam | awk -v mnd=1 -f ${juiceDir}/scripts/common/sam_to_pre.awk > ${outputdir}/merged_nodups.txt
