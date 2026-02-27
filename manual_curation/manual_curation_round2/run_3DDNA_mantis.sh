#!/bin/bash
#SBATCH -J run_3DDNA_mantis
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 36
#SBATCH --mem=1000G
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

set -e

echo -e "`date`:[M]: Host Name: `hostname`"

module load samtools/1.19 bwa/0.7.17 java/22
export PATH="${core}/bin/3d-dna:$PATH"
module load gnu-parallel/20160622 lastz/1.04.03 python/3.8.1

home=/home/FCAM/msmith
core=/core/projects/EBP/smith
scratch=/scratch/msmith
gid="intdf137"
site="Arima"
threads=36
jd=${scratch}/juicer_formanualcur
out_fulldir=${core}/3ddna_again
out_vis=${scratch}/3ddna
prim=${core}/CBP_assemblyfiles/interior_primary_final.fa
export TMPDIR=${scratch}

cd ${out_fulldir}
merged_nodups=${jd}/work/intdf137/aligned/merged_nodups.txt

if [[ ! -f interior_primary_final.0.hic ]] ; then
  cp ${out_vis}/interior_primary_final.0.hic .
fi

echo -e "\n`date`:[M]: Beginning full 3DDNA pipeline.\n"
${core}/bin/3d-dna/visualize/run-asm-pipeline.sh -f ${prim} ${merged_nodups}
