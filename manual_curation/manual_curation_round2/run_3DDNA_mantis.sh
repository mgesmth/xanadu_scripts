#!/bin/bash
#SBATCH -J run_3DDNA_mantis
#SBATCH -p himem
#SBATCH -q himem
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
out_vis=${scratch}/3ddna_2
prim=${core}/CBP_assemblyfiles/interior_primary_final.fa
merged_nodups=${jd}/work/intdf137/aligned/merged_nodups.txt
export TMPDIR=${scratch}

cd $out_vis
ls -1 * > copy_files.txt
cd ${out_fulldir}
for file in $(cat ${out_vis}/copy_files.txt) ; do
  cp ${out_vis}/${file} .
done

echo -e "\n`date`:[M]: Beginning full 3DDNA pipeline.\n"
${core}/bin/3d-dna/visualize/run-asm-pipeline.sh -f --splitter-coarse-stringency 65 \
--splitter-fine-resolution 2500000 --splitter-coarse-resolution 2500000 \
--editor-coarse-stringency 65 --editor-fine-resolution 2500000 \
--editor-coarse-resolution 2500000 ${prim} ${merged_nodups}
