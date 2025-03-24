#!/bin/bash
#SBATCH --job-name=test_scaffolds
#SBATCH --partition=general
#SBATCH --qos=general
#SBATCH --cpus-per-task=24
#SBATCH --mem=7500G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=meg8130@student.ubc.ca
#SBATCH -o scaffolds_1.%j.out
#SBATCH -e scaffolds_1.%j.err

core=/core/projects/EBP/smith
home=/home/FCAM/msmith
scratch=/scratch/msmith
primary=${core}/CBP_assemblyfiles/interior_primary_final.fa
alternate=${core}/CBP_assemblyfiles/interior_alternate_final.fa
coastal=${core}/coastal_assembly/
out_prefix1=${home}/minigraph_out/interior_all
out_prefix2=${home}/minigraph_out/interior_coastal_all

export PATH="${core}/bin/minigraph:$PATH"
export PATH="${core}/bin/gfatools:$PATH"

minigraph -cxggs -t 24 ${primary} ${alternate} > "${out_prefix1}.gfa"
gfatools bubble "${out_prefix1}.gfa" > "${out_prefix1}.bed"
minigraph -cxggs -t 24 "${out_prefix1}.gfa" ${coastal} > "${out_prefix2}.gfa"
gfatools bubble "${out_prefix2}.gfa" > "${out_prefix2}.bed"
