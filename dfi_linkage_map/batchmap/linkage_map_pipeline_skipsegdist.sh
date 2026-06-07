#!/bin/bash
#SBATCH -J create_LGs
#SBATCH -p general
#SBATCH -q general
#SBATCH -D /core/projects/EBP/smith/linkage_snp_calling_final/11_batchmap_physbin100kb_prebin
#SBATCH -c 24
#SBATCH --mem=128G
#SBATCH --mail-user=meg8130@student.ubc.ca
#SBATCH --mail-type=ALL
#SBATCH -o /core/projects/EBP/smith/linkage_snp_calling_final/11_batchmap_physbin100kb_prebin/log/%x.%j.out
#SBATCH -e /core/projects/EBP/smith/linkage_snp_calling_final/11_batchmap_physbin100kb_prebin/log/%x.%j.err

set -e
echo `hostname`

module load python/3.13.11-gcc-11.4.0-kifh66l

core=/core/projects/EBP/smith
batchmap=${core}/bin/batchmap.sif
dir=${core}/linkage_snp_calling_final/11_batchmap_physbin100kb_prebin
scripts=${dir}/scripts
if [[ ! -d ${scripts} ]] ; then
  ln -s /home/FCAM/msmith/scripts/dfi_linkage_map/batchmap ./scripts
fi

cd ${dir}
mark1=$1
#linkage_snp_calling_unsplit_batchmap_standard.txt
mark2=${mark1%.txt}_segpass.txt
num_samp=100
max_rf=$2
LOD=$3

echo -e "\n[M]: Finding linkage groups..."

cp ${scripts}/batchmap_createLGs.R .
singularity exec ${batchmap} Rscript batchmap_createLGs.R ${dir} ${mark2} ${max_rf} ${LOD}
rm batchmap_createLGs.R

###

#Create maps for each LG in parallel

#num_LGs=13
#array=$((${num_LGs2}-1))

#sbatch -J LG_batchmap -p general -q general \
#--array=[0-${array}] \
#-c 24 --mem=128G --mail-user=meg8130@student.ubc.ca \
#--mail-type=ALL -o %x.%A.%a.out -e %x.%A.%a.err \
#../01_scripts/parallel_batchmaps.sh
