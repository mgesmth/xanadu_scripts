#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=12
#SBATCH --partition=general
#SBATCH --qos=general
#SBATCH --mail-type=ALL
#SBATCH --mem=50G
#SBATCH --mail-user=meg8130@student.ubc.ca
#SBATCH -o quast1_2.%j.out
#SBATCH -e quast1_2.%j.err

module load quast/5.2.0

indir=/core/projects/EBP/smith/scaffold
outdir=/home/FCAM/msmith/quast_out/1_2
quast=/isg/shared/apps/quast/5.2.0/quast.py

python3 $quast -t 12 --split-scaffolds --large \ 
${indir}/intDF011_scaffolds_final.fasta -o $outdir




