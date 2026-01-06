#!/bin/bash
#SBATCH -J split_bam
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 36
#SBATCH --mem=250G
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

set -e
echo -e "`date`:[M]: Host Name: `hostname`"

module load samtools/1.19
home=/home/FCAM/msmith
core=/core/projects/EBP/smith
scratch=/scratch/msmith
sandbox=/sandbox/msmith
juiceDir=${sandbox}/juicer_formanualcur
topDir=${juiceDir}/work/intdf137
outputdir=${topDir}/aligned
scaff="scaffold_9_primary"
export PATH="${core}/CBP_assemblyfiles:${PATH}"

samtools view -@ 36 -b -o ${scratch}/scaffold_9_primary.bam ${outputdir}/merged_dedup.bam "$scaff"
