#!/bin/bash
#SBATCH -J RepeatModeler
#SBATCH -p himem
#SBATCH -q himem
#SBATCH -c 24
#SBATCH --mem=500G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=meg8130@student.ubc.ca
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

echo `hostname`

dir=/scratch/msmith/repeatModeler
core=/core/projects/EBP/smith
module load RepeatModeler/2.0.4

singularity shell /isg/shared/apps/RepeatModeler/2.0.4/TETOOLS.sif 
RepeatModeler -database "${dir}/primary_db/primary" -threads 24 -LTRStruct
