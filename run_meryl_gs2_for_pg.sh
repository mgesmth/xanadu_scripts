#!/bin/bash
#SBATCH -J kmers
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 24
#SBATCH --mem=150G
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
pg_dir=${home}/whitespruce_hifi
outdir=${pg_dir}/kmers
k=22
threads="$(getconf _NPROCESSORS_ONLN)"
meryl_db=piceaglauca_hifi.meryl
if [[ ! -d ${outdir} ]] ; then
  mkdir ${outdir}
fi

echo "`date`:[M]: Hey! We are getting k-mer based genome quality estimates for Picea glauca."
echo -e "`date`:[M]: Please note we are running this analysis with 6 of 8 HiFi cells.\n"

if [[ ! -f hifi.iterator ]] ; then
  cd ${pg_dir}
  ls -1 *.fastq.gz > hifi.iterator
fi

cd ${outdir}

for read in $(cat ../hifi.iterator) ; do
  pfx=${read//.fastq.gz/}
  meryl k=$k count output ${pfx}.meryl ../${read}
done

echo -e "\n`date`:[M]: Done counting individual hifi fastqs. Running union-sum...\n"

meryl union-sum output ${meryl_db} m*.meryl

echo -e "\n`date`:[M]: Meryl db created. Generating histogram...\n"

meryl histogram threads=${threads} k=$k ${meryl_db} > "${meryl_db}.hist"

echo -e "\n`date`:[M]: Done generating histogram. Running GenomeScope2...\n"

genomescope.R -i "${meryl_db}.hist" -o . -k ${k}

echo -e "\n`date`:[M]: K-mer analysis complete. Bye!"


