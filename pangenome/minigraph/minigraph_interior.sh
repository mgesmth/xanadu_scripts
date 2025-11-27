#!/bin/bash
#SBATCH --job-name=minigraph
#SBATCH --partition=himem2
#SBATCH --qos=himem
#SBATCH --cpus-per-task=36
#SBATCH --mem=1250G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=meg8130@student.ubc.ca
#SBATCH -o minigraph_interior.%j.out
#SBATCH -e minigraph_interior.%j.err

echo `hostname`

home=/home/FCAM/msmith
core=/core/projects/EBP/smith
prim=${core}/manual_curation_files/interior_primary_final_mancur_1Mb.fa
alt=${core}/CBP_assemblyfiles/interior_alternate_1Mb.fa
outdir=${home}/minigraph_justint/interior_pangenome
outfix="interior_pangenome"
out=${home}/minigraph_justint/${outfix}

cd $outdir

#EXEC
export PATH="${core}/bin/zlib-1.3.1:$PATH"
module load java/17.0.2
module load bedtools/2.29.0
export PATH="${core}/bin/minigraph-0.21:$PATH"
export PATH="${core}/bin/minigraph-0.21/mg-cookbook-v1_x64-linux:$PATH"
export PATH="${core}/bin/gfatools:$PATH"
k8_dir=${core}/bin/minigraph-0.21/mg-cookbook-v1_x64-linux
misc_dir=${core}/bin/minigraph-0.21/misc

minigraph -cxggs -t 36 ${prim} ${alt} > "${out}.gfa"
gfatools bubble "${out}.gfa" > "${out}_unfiltered.bed"
gfatools stat "${out}.gfa" > "${out}.stat"
minigraph -cxasm --call -t 36 "${out}.gfa" ${prim} > "${out}_primcall.bed"
minigraph -cxasm --call -t 36 "${out}.gfa" ${alt} > "${out}_altcall.bed"

primcall_prefix=$(basename "${out}_primcall.bed" | sed 's/.bed//')
altcall_prefix=$(basename "${out}_altcall.bed" | sed 's/.bed//')
mkdir minigraph_tmp
cd minigraph_tmp
cp "${out}_primcall.bed" .
cp "${out}_altcall.bed" .

if [[ -f "${out}_primcall.bed" && -f "${out}_altcall.bed" ]] ; then
  echo -e "${outfix}_primcall.bed\n${outfix}_altcall.bed" > samples.txt
  bed_rightorder=$(echo "${primcall_prefix}.bed ${altcall_prefix}.bed")
  paste ${bed_rightorder} | ${k8_dir}/k8 ${misc_dir}/mgutils.js merge -s samples.txt - | gzip -c > "${outfix}.sv.bed.gz"
  ${k8_dir}/k8 ${misc_dir}/mgutils-es6.js merge2vcf -a1 -r0 "${outfix}.sv.bed.gz" > "${out}_unfiltered.sv.vcf"

  #filter vcf
  unfvcf="${outdir}/${prx}_unfiltered.sv.vcf"
  awk '/^#/ {print} !/^#/ && $10 != "." && $11 != "." && $12 != "." {print}' ${unfvcf} | \
  awk '/^#/ {print} !/^#/ && $11 ~ /1:1/ || $12 ~ /1:1/ {print}' > "${out}_filtered1.sv.vcf"
  cd ..
  rm -r minigraph_tmp

  #filter other files
  awk 'BEGIN { OFS="\t" } /^#/ {next} !/^#/ {
    split($8,m,";")
    split(m[1],n,"=")
    print $1,$2,n[2] }' "${out}_filtered1.sv.vcf" > filtered_coordinates.bed

  bedtools intersect -F 1 -wa -a "${out}_primcall.bed" -b filtered_coordinates.bed  > "${out}_primcall_filtered.bed" && \
  bedtools intersect -F 1 -wa -a "${out}_altcall.bed" -b filtered_coordinates.bed > "${out}_altcall_filtered.bed" && \
  bedtools intersect -F 1 -wa -a "${out}_unfiltered.bed" -b filtered_coordinates.bed > "${out}_filtered.bed"
