#!/bin/bash
#SBATCH -J run_juicer_merge
#SBATCH -p himem2
#SBATCH -q himem
#SBATCH -c 36
#SBATCH --mem=1000G
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=meg8130@student.ubc.ca
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

set -e

echo -e "`date`:[M]: Host Name: `hostname`"

module load samtools/1.20 bwa/0.7.17 java-sdk/1.8.0_92
export PATH="${core}/bin/3d-dna:$PATH"
module load gnu-parallel/20160622 lastz/1.04.03 python/3.8.1

home=/home/FCAM/msmith
core=/core/projects/EBP/smith
scratch=/scratch/msmith
sandbox=/sandbox/msmith
gid="intdf137"
site="Arima"
threads=36
jd=${sandbox}/juicer_formanualcur
export TMPDIR=${core}
out_fulldir=${core}/manual_curation_round2/3DDNA_pipeline
out_mancurdir=${core}/manual_curation_round2/3DDNA_justmancur

echo "`date`:[M]: Beginning juicer run."

cd ${jd}
#Okay - now run juicer (CPU version, modified for better handling of large files)
scripts/juicer_mergeonly.sh -f --assembly -g "$gid" -d "${jd}/work/intdf137" -s "$site" -S merge \
-p references/intdf137.chrom.sizes -y restriction_sites/intdf137_Arima.txt \
-z references/interior_primary_final.fa -D "$jd" -t "$threads"

echo -e "\n`date`:[M]: Juicer merge complete."
