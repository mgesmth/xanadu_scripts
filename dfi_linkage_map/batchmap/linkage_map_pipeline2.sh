#!/bin/bash
#SBATCH -J create_LGs
#SBATCH -p general
#SBATCH -q general
#SBATCH -D /core/projects/EBP/smith/linkage_snp_calling/11_batchmap
#SBATCH -c 24
#SBATCH --mem=128G
#SBATCH --mail-user=meg8130@student.ubc.ca
#SBATCH --mail-type=ALL
#SBATCH -o /core/projects/EBP/smith/linkage_snp_calling/11_batchmap/log/%x.%j.out
#SBATCH -e /core/projects/EBP/smith/linkage_snp_calling/11_batchmap/log/%x.%j.err

set -e
echo `hostname`

module load python/3.13.11-gcc-11.4.0-kifh66l

core=/core/projects/EBP/smith
batchmap=${core}/bin/batchmap.sif
dir=${core}/linkage_snp_calling/11_batchmap

cd ${dir}
mark1=DFI_linkage_stringent_maf.txt
binned_raw=DFI_linkage_stringent_maf_binned.raw
mark2=DFI_linkage_stringent_maf_binned_segpass.txt
num_samp=100

cp /core/projects/EBP/smith/linkage_snp_calling/01_scripts/onemap_functions_for_batchmap.R .
singularity exec ${batchmap} Rscript onemap_functions_for_batchmap.R
rm onemap_functions_for_batchmap.R

cp ${scripts}/batchmap_createLGs_fromstart.R .
singularity exec ${batchmap} batchmap_createLGs_fromstart.R ${dir} ${mark1} "LGs_createD_fromstart.RData"
rm batchmap_createLGs_fromstart.R 

###

#Create maps for each LG in parallel

#num_LGs=13
#array=$((${num_LGs2}-1))

#sbatch -J LG_batchmap -p general -q general \
#--array=[0-${array}] \
#-c 24 --mem=128G --mail-user=meg8130@student.ubc.ca \
#--mail-type=ALL -o %x.%A.%a.out -e %x.%A.%a.err \
#../01_scripts/parallel_batchmaps.sh
