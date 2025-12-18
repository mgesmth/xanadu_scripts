#!/bin/bash
#SBATCH -J kmers
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 12
#SBATCH --mem=80G
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

set -e
echo -e "`date`:[M]: Host Name: `hostname`"

##EXECUTABLES---
module load R/4.2.2
export PATH="/home/FCAM/msmith/R/x86_64-pc-linux-gnu-library/4.2:$PATH"
module load meryl/1.4.1
module load merqury/1.3
export PATH="/core/projects/EBP/smith/bin/genomescope2.0:$PATH"

##DATA STRUCTURES---
home=/home/FCAM/msmith
core=/core/projects/EBP/smith
pg_dir=${home}/whitespruce_hifi
outdir=${core}/whitespruce_kmers
k=22
threads="$(getconf _NPROCESSORS_ONLN)"
meryl_db=piceaglauca_hifi.meryl

echo "`date`:[M]: Hey! We are getting k-mer based genome quality estimates for Picea glauca."
echo -e "`date`:[M]: Please note we are running this analysis with 6 of 8 HiFi cells.\n"

cd ${outdir}

echo -e "\n`date`:[M]: Running GenomeScope2...\n"

genomescope.R -i "${meryl_db}.hist" -o . -k ${k}

echo -e "\n`date`:[M]: K-mer analysis complete. Bye!"
