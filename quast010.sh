#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=12
#SBATCH --partition=himem
#SBATCH --qos=himem
#SBATCH --mail-type=ALL
#SBATCH --mem=50G
#SBATCH --mail-user=meg.smith@ubc.ca
#SBATCH -o quast1_0_%j.out
#SBATCH -e quast1_0_%j.err

module load quast/5.2.0

indir=/home/FCAM/msmith/hifiasm1_0
quast=/isg/shared/apps/quast/5.2.0/quast.py

python3 $quast -e $indir/intDF010.asm.bp.p_ctg.fasta -o $indir/quast_out




