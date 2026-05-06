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
scripts=${dir}/scripts
if [[ ! -d ${scripts} ]] ; then
  ln -s /home/FCAM/msmith/scripts/dfi_linkage_map/batchmap ./scripts
fi

cd ${dir}
mark1=DFI_linkage_stringent_maf.txt
mark2=DFI_linkage_stringent_maf_segpass.txt
num_samp=100

echo -e "\n[M]: Finding segregation distorters...\n"
cp ${scripts}/batchmap_segdist.R .
singularity exec ${batchmap} Rscript batchmap_segdist.R ${dir} ${mark1}
rm onemap_functions_for_batchmap.R

echo -e "\n[M]: Removing segregation distorters...\n"

#remove segregation distorters
awk 'NR==FNR{
  if ($1 ==)
  passed_arr[$1]=1
  next
}{
  #if the line is a marker line and not the header
  if ($0 ~ "scaffold") {
    mark=substr($1,2,length($1))
    if (mark in passed_arr) {
      print
    } else {
      next
    }
  } else {
    #if the header line
    print
  }
}' seg_passed_markers_notbinned.tsv ${mark1} > ${mark2}

echo -e "\n[M]: Finding linkage groups..."

cp ${scripts}/batchmap_createLGs.R .
singularity exec ${batchmap} Rscript batchmap_createLGs.R ${dir} ${mark1} "LGs_created.RData"
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
