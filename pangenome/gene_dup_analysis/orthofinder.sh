#!/bin/bash
#SBATCH -J orthofinder
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 12
#SBATCH --mem=36G
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

set -e
date
echo "[M]: Host Name: `hostname`"

home=/home/FCAM/msmith
core=/core/projects/EBP/smith
ortho_dir=${home}/orthofinder
prot_dir=${ortho_dir}/proteomes
int_pep=${core}/eviann_justint/interior_primary_mancur_masked_500kb.justint.proteins.fa
coa_pep=${core}/eviann_justcoa/coastal_masked_500kb.justcoa.proteins.fa

. ${core}/bin/orthofinder_venv/bin/activate

orthofinder -t 6 -a 6 -n "ortho_run1out" -f ${prot_dir}
