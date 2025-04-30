#!/bin/bash
#SBATCH -J minigraph_prep_p
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 8
#SBATCH --mem=50G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=meg8130@student.ubc.ca
#SBATCH -o minigraph_prepp.%j.out
#SBATCH -e minigraph_prepp.%j.err

echo `hostname`

module load seqkit/2.10.0

home=/home/FCAM/msmith
core=/core/projects/EBP/smith
scratch=/scratch/msmith
alternate=${core}/CBP_assemblyfiles/interior_alternate_1Mb.fa
coastal=${core}/coastal/coastalDF_scaffrenamed_sorted_1Mb.fa
primary=${core}/CBP_assemblyfiles/interior_primary_1Mb.fa

for scaffold in `awk '$2 ~ "scaffold" {print $2}' ${home}/GSAlign/topalignments_alternate.txt ${home}/GSAlign/topalignments_coastal.txt | sort -g -t '_' -k2 | uniq`; do
  seqkit grep -n -p "${scaffold}" ${primary} > "${scratch}/minigraph_prep/primary_fastas/${scaffold}.fa"
done
