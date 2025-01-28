#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=12
#SBATCH --partition=general
#SBATCH --qos=general
#SBATCH --mail-type=ALL
#SBATCH --mem=250G
#SBATCH --mail-user=meg8130@student.ubc.ca
#SBATCH -o quast1_1_%j.out
#SBATCH -e quast1_1_%j.err

module load quast/5.2.0

home=/home/FCAM/msmith
contigs=${home}/yahs/contigs/intDF011.asm.hic.p_ctg.fasta
refdir=${home}/Psme.1_0
outdir=${home}/quast_out/1_1_genes

python3 quast.py -t 12 -o $outdir --large --k-mer-stats \
-r ${refdir}/Psme.1_0.fa.gz -g ${refdir}/Psme.1_0.gff \
$contigs




