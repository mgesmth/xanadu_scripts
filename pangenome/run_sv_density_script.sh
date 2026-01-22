#!/bin/bash
#SBATCH -J svjob
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 10
#SBATCH --mem=36G
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

set -e
echo "`date`:[M]: Host Name: `hostname`"

scripts=/home/FCAM/msmith/scripts
core=/core/projects/EBP/smith
pg_dir=${core}/minigraph
pg=${pg_dir}/final_finalpangenome.gfa
fai=${core}/manual_curation_files/interior_primary_final_mancur_1Mb.fa.fai
window=10000000

export PATH="${core}/bin/gfatools:$PATH"

echo -e "`date`:[M]: Beginning calculation of SV density by sequence coverage.\n"

${scripts}/pangenome/sv_density_windowed_bypangenome.sh \
-p ${pg} -f ${fai} -w ${window}

echo -e "\n`date`:[M]: Complete all calculations. Bye!"
