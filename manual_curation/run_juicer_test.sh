#!/bin/bash
#SBATCH -J run_juicer
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 12
#SBATCH --mem=48G
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=meg8130@student.ubc.ca
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

set -e

echo "[M]: Host Name: `hostname`"

home=/home/FCAM/msmith
core=/core/projects/EBP/smith
scratch=/scratch/msmith
gid="intdf137"
site="Arima"
threads=12
jd=${scratch}/juicer_formanualcur

echo "[M]: Beginning juicer run."
cd ${jd}
#Okay - now run juicer (CPU version, modified for better handling of large files)
scripts/juicer.sh -g "$gid" -d "${jd}/work/test" -s "$site" -S "chimeric" \
-p references/intdf137.chrom.sizes -y restriction_sites/intdf137_Arima.txt \
-z references/interior_primary_final.fa -D "$jd" -t "$threads"
if [[ $? -e 0 ]] ; then
  echo "[M]: Juicer complete! Bye."
  date
  exit 0
else
  echo "[E]: Juicer failed. Exit code $?"
  date
  exit 1
fi
