#!/bin/bash
#SBATCH -J run_juicer_merge
#SBATCH -p himem2
#SBATCH -q himem
#SBATCH -c 6
#SBATCH --mem=1000G
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=meg8130@student.ubc.ca
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

set -e

echo -e "`date`:[M]: Host Name: `hostname`"

module load samtools/1.20
module load bwa/0.7.17
module load java-sdk/1.8.0_92

home=/home/FCAM/msmith
core=/core/projects/EBP/smith
scratch=/scratch/msmith
gid="intdf137"
site="Arima"
threads=36
jd=${core}/juicer_formanualcur

echo "`date`:[M]: Beginning juicer run."

cd ${jd}
#Okay - now run juicer (CPU version, modified for better handling of large files)
scripts/juicer.sh -f --assembly -g "$gid" -d "${jd}/work/intdf137" -s "$site" -S merge \
-p references/intdf137.chrom.sizes -y restriction_sites/intdf137_Arima.txt \
-z references/interior_primary_final.fa -D "$jd" -t "$threads"
