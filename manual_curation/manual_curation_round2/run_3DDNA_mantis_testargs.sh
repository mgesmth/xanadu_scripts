#!/bin/bash
#SBATCH -J run_3DDNA_mantis_testargs
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 2
#SBATCH --mem=4G
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
out_vis=${scratch}/3ddna_2
prim=${core}/CBP_assemblyfiles/interior_primary_final.fa
merged_nodups=${jd}/work/intdf137/aligned/merged_nodups.txt
export TMPDIR=${scratch}

cd ${out_fulldir}

echo -e "\n`date`:[M]: Beginning full 3DDNA pipeline.\n"
${core}/bin/3d-dna/run-asm-pipeline.sh -f --splitter-coarse-stringency 65 \
--splitter-fine-resolution 1000000 --splitter-coarse-resolution 2500000 \
--editor-coarse-stringency 65 --editor-fine-resolution 500000 \
--editor-coarse-resolution 1000000 --editor-coarse-region 3000000 \
${prim} ${merged_nodups}
