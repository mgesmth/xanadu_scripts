#!/bin/bash
#SBATCH -J mergeredo
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

#create merged30.txt
samtools view -@ 24 -F 1024 -O sam ${outputdir}/merged_dedup.bam | awk -v mapq=30 -f ${juiceDir}/scripts/common/sam_to_pre.awk > ${outputdir}/merged30.txt

#index the merged*.txt files
time ${juiceDir}/scripts/common/index_by_chr.awk ${outputdir}/merged1.txt 500000 > ${outputdir}/merged1_index.txt
time ${juiceDir}/scripts/common/index_by_chr.awk ${outputdir}/merged30.txt 500000 > ${outputdir}/merged30_index.txt

#Create the inter files - these would be used for HiC
dups=$(samtools view -c -f 1089 -F 256 -@ 24 $outputdir/merged_dedup.bam)
cat $splitdir/*.res.txt | awk -v dups=$dups -v ligation=$ligation -f ${juiceDir}/scripts/common/stats_sub.awk >> $outputdir/inter.txt
cp $outputdir/inter.txt $outputdir/inter_30.txt

${juiceDir}/scripts/common/juicer_tools statistics $site_file $outputdir/inter.txt $outputdir/merged1.txt none
${juiceDir}/scripts/common/juicer_tools statistics $site_file $outputdir/inter_30.txt $outputdir/merged30.txt none

samtools view -@ 24 -O SAM -F 1024 $outputdir/merged_dedup.bam | awk -v mnd=1 -f ${juiceDir}/scripts/common/sam_to_pre.awk > ${outputdir}/merged_nodups.txt
