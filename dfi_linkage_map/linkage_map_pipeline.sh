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

module load python/3.13.11-gcc-11.4.0-kifh66l

core=/core/projects/EBP/smith
batchmap=${core}/bin/batchmap.sif
dir=${core}/linkage_snp_calling/11_batchmap

cd ${dir}
mark1=DFI_linkage_stringent_maf.txt
binned_raw=DFI_linkage_stringent_maf_binned.raw
mark2=DFI_linkage_stringent_maf_binned_segpass.txt
num_samp=100


#singularity exec ${batchmap} \
#Rscript ../01_scripts/batchmap_segdist.R "$mark1" "$binned_raw"
#transform onemap raw file to batchmap txt file
#python ../01_scripts/onemap_raw_to_batchmap_txt.py "$binned_raw" tmp.txt

#remove segregation distorters from map
#awk 'NR==FNR{
#  if ($1 == "marker") {
#    next
#  } else {
#    passed_arr[$1]=1
#  }
#  next
#}{
#  if ($0 ~ "scaffold") {
#    marker=substr($1,2,length($1))
#    if (marker in passed_arr) {
#      print
#    } else {
#      next
#    }
#  } else {
#    next
#  }
#}' seg_passed_markers.tsv tmp.txt > tmp1.txt

#num_marks=$(cat tmp1.txt | wc -l)
#echo "${num_samp} ${num_marks} 0" > ${mark2}
#cat tmp1.txt >> ${mark2}
#rm tmp.txt tmp1.txt


###
#Now create linkage groups
cp ../01_scripts/batchmap_createLGs.R .
singularity exec ${batchmap} RScript batchmap_createLGs.R ${dir} ${mark2}
rm batchmap_createLGs.R

#Create maps for each LG in parallel

#num_LGs=13
#array=$((${num_LGs2}-1))

#sbatch -J LG_batchmap -p general -q general \
#--array=[0-${array}] \
#-c 24 --mem=128G --mail-user=meg8130@student.ubc.ca \
#--mail-type=ALL -o %x.%A.%a.out -e %x.%A.%a.err \
#../01_scripts/parallel_batchmaps.sh
