#!/bin/bash
#SBATCH -J run_3DDNA
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

module load samtools/1.20 bwa/0.7.17 java/22
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
prim=${core}/CBP_assemblyfiles/interior_primary_final.fa

cd ${out_fulldir}
merged_nodups=${jd}/work/intdf137/aligned/merged_nodups.txt

echo -e "\n`date`:[M]: Beginning full 3DDNA pipeline.\n"
${core}/bin/3d-dna/run-asm-pipeline.sh ${prim} ${merged_nodups}

echo -e "\n`date`:[M]: Done full 3DDNA pipeline."
