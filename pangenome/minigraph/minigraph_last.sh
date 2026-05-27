#!/bin/bash
#SBATCH -J minigraph_last
#SBATCH -p himem
#SBATCH -q himem
#SBATCH -c 36
#SBATCH --mem=1200G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=meg8130@student.ubc.ca
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

set -e

echo "[M]: Host Name: `hostname`"

#Please let this be the last time!

home=/home/FCAM/msmith
core=/core/projects/EBP/smith
scratch=/scratch/msmith
minidir=${home}/minigraph
prim=${core}/final_genome/psme_glauca_primary_bigscaffoldsplit.fa
alt=${scratch}/interior_alternate_1Mb.fa
out_prefix="lastpangenome"
threads="36"
gfa="${minidir}/${out_prefix}.gfa"
k8_dir=${core}/bin/minigraph-0.21/mg-cookbook-v1_x64-linux
misc_dir=${core}/bin/minigraph-0.21/misc

prim_prefix=$(basename "$prim" | sed 's/.fa//')
alt_prefix=$(basename "$alt" | sed 's/.fa//')

#programs
export PATH="${core}/bin/minigraph-0.21:$PATH"
export PATH="${core}/bin/minigraph-0.21/mg-cookbook-v1_x64-linux:$PATH"
export PATH="${core}/bin/gfatools:$PATH"

#--------------------

date
echo "[M]: Beginning pangenome construction."
minigraph -cxggs -t "$threads" "$prim" "$alt" "$coast" > "$gfa"

echo "[M]: Pangenome construction complete. Moving on to extracting variants and calling paths."

gfatools bubble "$gfa" > "${minidir}/${out_prefix}_unfiltered.bed"
minigraph -xasm --call -t "$threads" "$gfa" "$prim" > "${minidir}/${prim_prefix}.bed"
minigraph -xasm --call -t "$threads" "$gfa" "$alt" > "${minidir}/${alt_prefix}.bed"
echo "[M]: Bubbles popped and paths called. Moving onto VCF file creation."

mkdir ${scratch}/minigraph_tmp
cd ${scratch}/minigraph_tmp
#Get copies of the path files into a temp file so I can run the utils command properly
cp "${minidir}/${prim_prefix}.bed" .
cp "${minidir}/${alt_prefix}.bed" .
echo -e "${prim_prefix}.bed\n${alt_prefix}.bed" > samples.txt
paste *.bed | ${k8_dir}/k8 ${misc_dir}/mgutils.js merge -s samples.txt - | gzip -c > "${out_prefix}.sv.bed.gz"

${k8_dir}/k8 ${misc_dir}/mgutils-es6.js merge2vcf -r0 "${out_prefix}.sv.bed.gz" > "${minidir}/${out_prefix}.sv.vcf"

#Filtering for missing data then for where there's an alt allele are the reference allele
awk '/^#/ {print ; next} $10 != "." {print}' "${minidir}/${out_prefix}.sv.vcf" | \
awk '/^#/ {print ; next} $11 ~ /1:1/ {print}' > "${minidir}/${out_prefix}_filtered1.sv.vcf"

cd ..
rm -r minigraph_tmp

cd ${minidir}

module load bedtools/2.31.1
#get the coordinates of filtered variants
awk 'BEGIN { OFS="\t" } /^#/ {next} !/^#/ {
  split($8,m,";")
  split(m[1],n,"=")
  print $1,$2,n[2] }' "${out_prefix}_filtered1.sv.vcf" > filtered_coordinates.bed

#recover filtered versions of bed files
bedtools intersect -F 1 -wa -a "${prim_prefix}.bed" -b filtered_coordinates.bed  > "${out_prefix}_primcall_filtered1.bed"
bedtools intersect -F 1 -wa -a "${alt_prefix}.bed" -b filtered_coordinates.bed > "${out_prefix}_altcall_filtered1.bed"
bedtools intersect -F 1 -wa -a "${out_prefix}_unfiltered.bed" -b filtered_coordinates.bed > "${out_prefix}_filtered1.bed"

echo "[M] Done!"
