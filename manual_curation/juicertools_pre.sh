#!/bin/bash
#SBATCH -J juicertools_pre
#SBATCH -p himem2
#SBATCH -q himem
#SBATCH -c 36
#SBATCH --mem=1000G
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=meg8130@student.ubc.ca
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

date
echo "[M]: Host Name: `hostname`"
module load java/17.0.2
module load python/3.8.1

home=/home/FCAM/msmith
scratch=/scratch/msmith
core=/core/projects/EBP/smith
topdir=${scratch}/juicer_formanualcur

JUICER=${topdir}/scripts/common/juicer_tools.jar
threads="36"
tmpdir=${scratch}
output="${core}/interior_primary_final.hic"
chromsizes=${core}/CBP_assemblyfiles/interior_primary_final.chrom.sizes
contacts=${topdir}/work/intdf137/aligned/merged_nodups.txt
res_sites=/scratch/msmith/juicer_formanualcur/restriction_sites/intdf137_Arima.txt

mv ${topdir}/work/intdf137/aligned/merged_dedup.bam /core/projects/EBP/smith

java -XX:+UseParallelGC -Xms250G -Xmx1000G -jar $JUICER pre -f "$res_sites" -v -t "${tmpdir}" "${contacts}" "${output}" /core/projects/EBP/smith/CBP_assemblyfiles/interior_primary_final.chrom.sizes


