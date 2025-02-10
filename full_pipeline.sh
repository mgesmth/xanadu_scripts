#!/bin/bash
#SBATCH --job-name=intdfassem
#SBATCH --nodes=1
#SBATCH --cpus-per-task=36
#SBATCH --mem=1000G
#SBATCH --partition=himem2
#SBATCH --qos=himem
#SBATCH --mail-user=meg8130@student.ubc.ca
#SBATCH -o intdfassem.%j.out
#SBATCH -e intdfassem.%j.err

echo `hostname`

#main directories
home=/home/FCAM/msmith
core=/core/projects/EBP/smith
scratch=/scratch/msmith

##Quality control and adapter trim ---
module load fastp


##Primary assembly ---

hifi=${home}/hifi_data
hic=${home}/hiC_data/all
outdir
module load Hifiasm/0.20.0

hifiasm -o 
