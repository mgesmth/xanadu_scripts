#!/bin/bash
#SBATCH --job-name=test_scaffolds
#SBATCH --partition=general
#SBATCH --qos=general
#SBATCH --cpus-per-task=12
#SBATCH --mem=90G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=meg8130@student.ubc.ca
#SBATCH -o scaffolds_11_13.out
#SBATCH -e scaffolds_11_13.err

core=/core/projects/EBP/smith
home=/home/FCAM/msmith
scratch=/scratch/msmith
primary=${core}/CBP_assemblyfiles/interior_primary_2_3.fa
alternate=${core}/CBP_assemblyfiles/interior_alternate_2_3.fa
out_prefix=${home}/minigraph_out/interior_2_3

export PATH="${core}/bin/minigraph:$PATH"
export PATH="${core}/bin/gfatools:$PATH"

minigraph -cxggs -t 12 ${primary} ${alternate} > "${out_prefix}.gfa"
gfatools bubble "${out_prefix}.gfa" > "${out_prefix}.bed"
