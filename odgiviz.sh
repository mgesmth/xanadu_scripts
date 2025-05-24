#!/bin/bash
#SBATCH -J odgiviz
#SBATCH -p himem
#SBATCH -q himem
#SBATCH --mem=100G
#SBATCH -c 8
#SBATCH --mail-type=ALL
#SBATCH --mail-user=meg8130@student.ubc.ca
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

echo '[M]: Host Name: `hostname`'

home=/home/FCAM/msmith
core=/core/projects/EBP/smith
scratch=/scratch/msmith
outdir=${home}/odgi
odgicon=${core}/bin/odgi_0.9.2.sif

#singularity exec $odgicon \
#	odgi extract -P -r scaffold_1_primary_251:1307586-1595760 -i ${outdir}/all_brokenscaffolds.og -o ${outdir}/scaffold_1_primary_251:1307586-1595760.og

#singularity exec $odgicon \
#	odgi sort -O -i ${outdir}/scaffold_1_primary_251:1307586-1595760.og -o ${outdir}/scaffold_1_primary_251:1307586-1595760_sort.og

#singularity exec $odgicon \
#	odgi viz -i ${outdir}/scaffold_1_primary_251:1307586-1595760_sort.og -o ${outdir}/scaffold_1_primary_251:1307586-1595760.png

