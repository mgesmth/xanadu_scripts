#!/bin/bash
#SBATCH --job-name=script2
#SBATCH --nodes=1
#SBATCH --cpus-per-task=36
#SBATCH --partition=himem2
#SBATCH --qos=himem
#SBATCH --mail-type=ALL
#SBATCH --mem=1000G
#SBATCH --mail-user=meg.smith@ubc.ca
#SBATCH -o script2_%j.out
#SBATCH -e script2_%j.err

echo `hostname`
hifiasm=/isg/shared/apps/Hifiasm/0.20.0/hifiasm
hifidir=/home/FCAM/msmith/hifi_data #symlink to /seqdata
hiCdir=/home/FCAM/msmith/hiC_data
outdir=/home/FCAM/msmith/hifiasm_out/hifiasm1_1

#bin files are symlinked as well - they are in the /Wegrzyn directory. hifiasm should just find them.

module load Hifiasm/0.20.0

$hifiasm -o $outdir/intDF010.asm -t 36 \
--h1 $hiCdir/allhiC_R1.fastq.gz --h2 $hiCdir/allhiC_R2.fastq.gz \
-f 39 \
$hifidir/intDF_allhifi.fastq.gz
