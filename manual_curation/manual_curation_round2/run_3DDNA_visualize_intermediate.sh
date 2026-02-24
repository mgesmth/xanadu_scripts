#!/bin/bash
#SBATCH -J run_3DDNA
#SBATCH -p himem2
#SBATCH -q himem
#SBATCH -c 36
#SBATCH --mem=1250G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=meg8130@student.ubc.ca
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

set -e

echo -e "`date`:[M]: Host Name: `hostname`"

module load samtools/1.20 bwa/0.7.17 java/17.0.2
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
prim=${core}/CBP_assemblyfiles/interior_primary_final.fa
export TMPDIR=${scratch}

cd ${out_fulldir}
merged_nodups=${jd}/work/intdf137/aligned/merged_nodups.txt
asm_mnd=${scratch}/temp.interior_primary_final.0.asm_mnd.txt

echo -e "\n`date`:[M]: Beginning full 3DDNA pipeline.\n"
${core}/bin/3d-dna/visualize/run-asm-visualizer.sh -i -m ${asm_mnd} interior_primary_final.0.cprops interior_primary_final.0.asm ${merged_nodups}
