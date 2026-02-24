#!/bin/bash
#SBATCH -J run_3DDNA
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 36
#SBATCH --mem=500G
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

set -e

echo -e "`date`:[M]: Host Name: `hostname`"

##Job kept failing on Xanadu, citing not enough RAM, but runs fine on Mantis with half RAM
#I think it's a java version issue. Running 3DDNA manually on mantis.

#scaffold with no error correction is already done. This is for with error correction.

module load samtools/1.19 bwa/0.7.17 java/22
export PATH="${core}/bin/3d-dna:$PATH"
module load gnu-parallel/20160622 lastz/1.04.03 python/3.8.1

home=/home/FCAM/msmith
core=/core/projects/EBP/smith
scratch=/scratch/msmith
threads=36
jd=${scratch}/juicer_formanualcur
out_fulldir=${core}/3ddna_again
out_vis=${scratch}/3ddna
prim=${core}/CBP_assemblyfiles/interior_primary_final.fa
export TMPDIR=${scratch}
merged_nodups=${jd}/work/intdf137/aligned/merged_nodups.txt

cd ${out_fulldir}

#round 1----
#defaults and variables
ROUND=1
pipeline=${core}/bin/3d-dna
genomeid="interior_primary_final"
orig_cprops=${genomeid}.cprops
orig_mnd=${genomeid}.mnd.txt

ln -sf ${orig_cprops} ${genomeid}.${ROUND}.cprops
ln -sf ${orig_mnd} ${genomeid}.mnd.${ROUND}.txt

echo "...starting round ${ROUND} of scaffolding:" >&1
bash ${pipeline}/scaffold/run-liger-scaffolder.sh -p true -s ${input_size} -q ${mapq} ${current_cprops} ${current_mnd}

asm_mnd=${scratch}/temp.interior_primary_final.0.asm_mnd.txt

echo -e "\n`date`:[M]: Beginning full 3DDNA pipeline.\n"
