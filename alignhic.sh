#!/bin/bash
#SBATCH --job-name=alignhic
#SBATCH --nodes=1
#SBATCH --cpus-per-task=24
#SBATCH --partition=himem
#SBATCH --qos=himem
#SBATCH --mail-type=ALL
#SBATCH --mem=150G
#SBATCH --mail-user=meg.smith@ubc.ca
#SBATCH -o alignhic_%j.out
#SBATCH -e alignhic_%j.err

echo `hostname`

module load bwa/0.7.17
module load samtools/1.20
module load picard/2.23.9

hic=/home/FCAM/msmith/hiC_data
outdir=/home/FCAM/msmith/yahs/bams
contigs=/home/FCAM/msmith/yahs/contigs/intDF011.asm.hic.p_ctg.fasta

#align reads and convert SAM to BAM (without writing to disk)
bwa mem $contigs $hic/allhiC_R1.fastq.gz $hic/allhiC_R2.fastq.gz \
-t 24 -R '@RG' | \
samtools view -bh | samtools sort -n > $outdir/aligned_hic_sorted.bam #sort BAM files by name (recommended by yahs)

#mark duplicates (also recommended by yahs)
java -jar $PICARD MarkDuplicates \
I=$outdir/aligned_hic_sorted.bam \
O=$outdir/aligned_hic_sorted_markdup.bam |
M=$outdir/markdup_metrics.txt
