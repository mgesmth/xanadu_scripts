#!/bin/bash
#SBATCH -J juicertools_pre
#SBATCH -p himem2
#SBATCH -q himem
#SBATCH -c 36
#SBATCH --mem=1200G
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=meg8130@student.ubc.ca
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

date
echo "[M]: Host Name: `hostname`"
module load java
module load python/3.8.1

home=/home/FCAM/msmith
scratch=/scratch/msmith
core=/core/projects/EBP/smith
topdir=${scratch}/juicer_formanualcur

JUICER=${topdir}/scripts/common/juicer_tools.jar
threads="36"
tmpdir=${scratch}
output="interior_primary_final"
chromsizes=${core}/CBP_assemblyfiles/interior_primary_final.chrom.sizes
contacts=${topdir}/work/intdf137/aligned/merged_dedup.bam

java -XX:+UseParallelGC -Xms250G -Xmx1200G -jar $JUICER pre -v --threads "${threads}" \
-t "${tmpdir}" -f ${topdir}/restriction_sites/intdf137_Arima.txt \
"${contacts}" "${output}.hic" "${chromsizes}"
