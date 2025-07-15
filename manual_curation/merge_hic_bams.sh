#!/bin/bash
#SBATCH -J merge_hic_bams
#SBATCH -p himem2
#SBATCH -q himem
#SBATCH -c 24
#SBATCH --mem=1000G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=meg8130@student.ubc.ca
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

echo "[M]: Host Name: `hostname`"

module load samtools/1.20
scratch=/scratch/msmith
bam_dir=${scratch}/hic_bams

cd ${bamdir}
ls -1 *.bam > bams.txt
samtools merge -@ 24 -b bams.txt -o ${scratch}/allhiC.allaln.bam
