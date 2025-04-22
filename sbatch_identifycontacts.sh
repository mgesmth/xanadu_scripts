#!/bin/bash
#SBATCH --job-name=alnhic
#SBATCH -p himem2
#SBATCH -q himem
#SBATCH -c 24
#SBATCH --mem=800G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=meg8130@student.ubc.ca
#SBATCH -o alnhic_%j.out
#SBATCH -e alnhic_%j.err

echo `hostname`

scratch=/scratch/msmith
out=${scratch}/interior_primary_hiCaln
primary=/core/projects/EBP/smith/CBP_assemblyfiles/interior_primary_final.fa
alternate=/core/projects/EBP/smith/CBP_assemblyfiles/interior_alternate_final.fa

/home/FCAM/msmith/scripts/identifycontacts.sh "${primary}" "${out}"
