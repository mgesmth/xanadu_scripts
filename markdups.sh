#!/bin/bash
#SBATCH --job-name=markdups
#SBATCH --partition=general
#SBATCH --qos=general
#SBATCH --nodes=1
#SBATCH --cpus-per-task=22
#SBATCH --mem=256G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=meg8130@student.ubc.ca
#SBATCH -o markdups_%j.out
#SBATCH -e markdups_%j.err

echo `hostname`
module load picard/2.23.9

home=/home/FCAM/msmith
scratch=/scratch/msmith
bwa_outdir=${home}/yahs/bams
contigs=${home}/yahs/contigs/intDF011.asm.hic.p_ctg.fasta
core=/core/projects/EBP/smith/scaffold

#mark duplicates (also recommended by yahs)
java -jar $PICARD MarkDuplicates \
-I ${scratch}/aligned_hic_sorted.bam -O ${core}/aligned_hic_sorted_markdup.bam -M ${bwa_outdir}/markdups_metrics.txt \
--TMP_DIR $(scratch}/
