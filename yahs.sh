#!/bin/bash
#SBATCH --job-name=scaffold
#SBATCH --partition=himem2
#SBATCH --qos=himem2
#SBATCH --nodes=1
#SBATCH --cpus-per-task=36
#SBATCH --mem=950G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=meg.smith@ubc.ca
#SBATCH -o scaffold_%j.out
#SBATCH -e scaffold_%j.err

echo `hostname`

module load YaHS/1.2.2

home=/home/FCAM/msmith/yahs
contigs=$home/contigs/intDF011.asm.hic.p_ctg.fasta
bam=$home/bams/aligned_hic_sorted_markdup.bam
outdir=/core/projects/EBP/smith/yahs

yahs $contigs $bam
