#!/bin/bash
#SBATCH -J mergeredo
#SBATCH -p general
#SBATCH -q general


module load samtools/1.19 java-sdk/1.8.0_92
home=/home/FCAM/msmith
core=/core/projects/EBP/smith
scratch=/scratch/msmith
sandbox=/sandbox/msmith
gid="intdf137"
site="Arima"
juiceDir=${sandbox}/juicer_formanualcur
topDir=${juiceDir}/work/intdf137
outputdir=${topDir}/aligned
export TMPDIR=${core}

samtools view -@ 24 -F 1024 -O sam ${outputdir}/merged_dedup.bam | awk -v mapq=1 -f ${juiceDir}/scripts/common/sam_to_pre.awk > ${scratch}/merged1.txt
