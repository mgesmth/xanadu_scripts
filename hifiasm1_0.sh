#!/bin/bash
#SBATCH --job-name=hifiasm1_0
#SBATCH --nodes=1
#SBATCH --cpus-per-task=36
#SBATCH --partition=himem
#SBATCH --qos=himem
#SBATCH --mail-type=ALL
#SBATCH --mem=500G
#SBATCH --mail-user=meg.smith@ubc.ca
#SBATCH -o hifiasm1_0_%j.out
#SBATCH -e hifiasm1_0_%j.err

echo `hostname`
hifiasm=/isg/shared/apps/Hifiasm/0.20.0/hifiasm
dir=/core/projects/EBP/Wegrzyn/pseudotsuga
#symlink to hifi reads in /seqdata folder called hifi_reads

module load Hifiasm/0.20.0

$hifiasm -o $dir/hifiasm1_0/intDF010.asm -t 36 -f 39 $dir/hifi_reads
