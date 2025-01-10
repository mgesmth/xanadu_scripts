#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=12
#SBATCH --partition=himem
#SBATCH --qos=himem
#SBATCH --mail-type=ALL
#SBATCH --mem=50G
#SBATCH --mail-user=meg.smith@ubc.ca
#SBATCH -o quast1_1_%j.out
#SBATCH -e quast1_1_%j.err

module load quast/5.2.0

indir=/home/FCAM/msmith/hifiasm_out/hifiasm1_1
outdir=/home/FCAM/msmith/quast_out/1_1
quast=/isg/shared/apps/quast/5.2.0/quast.py

python3 $quast -e $indir/intDF011.asm.hic.p_ctg.fasta -o $outdir




