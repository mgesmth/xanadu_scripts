#!/bin/bash
#SBATCH -J minigraph_bed2vcf
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 8
#SBATCH --mem=40G
#SBATCH -o ${log}/%x.%j.out
#SBATCH -e ${log}/%x.%j.err

set -e
date
echo "[M]: Host Name: `hostname`"
echo "[M]: Beginning minigraph bed to vcf pipeline"

home=/home/FCAM/msmith
core=/core/projects/EBP/smith
scratch=/scratch/msmith
prim=${scratch}/interior_primary_final_mancur_bigscaffoldsplit.fa
alt=${scratch}/interior_alternate_1Mb.fa
coast=${scratch}/coastal_1Mb.fa
prx="final_finalpangenome"
outdir=${core}/manual_curation_files/minigraph

#executables
module load java/17.0.2
module load bedtools/2.29.0
export PATH="${core}/bin/minigraph-0.21:$PATH"
export PATH="${core}/bin/minigraph-0.21/mg-cookbook-v1_x64-linux:$PATH"
export PATH="${core}/bin/gfatools:$PATH"
k8_dir=/core/projects/EBP/smith/bin/minigraph-0.21/mg-cookbook-v1_x64-linux
misc_dir=${core}/bin/minigraph-0.21/misc
#NOTE: only k8_dir has the k8 module, but the minigraph misc dir has a bug fix necessary to genotype the SVs properly. refer accordingly. 

prim_prefix=$(basename "$prim" | sed 's/.fa//')
alt_prefix=$(basename "$alt" | sed 's/.fa//')
coast_prefix=$(basename "$coast" | sed 's/.fa//')

#Copy beds to a temp dir because you need to paste *.bed as part of the command
mkdir ${scratch}/minigraph_tmp
cd ${scratch}/minigraph_tmp
cp "${outdir}/${prx}_primcall.bed" .
cp "${outdir}/${prx}_altcall.bed" .
cp "${outdir}/${prx}_coastcall.bed" .

#check if the files were properly copied over (i.e, no upstream syntax issue), if good then execute
#this code is from the minigraph github
if [[ -f "${prx}_primcall.bed" && -f "${prx}_altcall.bed" && -f "${prx}_coastcall.bed" ]] ; then
  echo -e "${prim_prefix}.bed\n${alt_prefix}.bed\n${coast_prefix}.bed" > samples.txt
  paste *.bed | ${k8_dir}/k8 ${misc_dir}/mgutils.js merge -s samples.txt - | gzip -c > "${prx}.sv.bed.gz"
  if [[ $? -eq 0 ]] ; then
    ${k8_dir}/k8 ${misc_dir}/mgutils-es6.js merge2vcf -a2 -r0 "${prx}.sv.bed.gz" > "${outdir}/${prx}_unfiltered.sv.vcf"
    if [[ $? -eq 0 ]] ; then
      date
      echo "[M]: SV VCF created. Filtering and cleaning up..."
      unfvcf="${outdir}/${prx}_unfiltered.sv.vcf"

      #Filtering for missing data then for where all three alleles are the reference allele and all three alleles have a genotype
      awk '/^#/ {print} !/^#/ && $10 != "." && $11 != "." && $12 != "." {print}' ${unfvcf} | \
      awk '/^#/ {print} !/^#/ && $11 ~ /1:1/ || $12 ~ /1:1/ {print}' > "${outdir}/${prx}_filtered1.sv.vcf"

      #one additional filter at the summary step (note on that filter in the categorize_svs.py script)
      cd ..
      rm -r minigraph_tmp

      echo "[M]: Done cleanup. Beginning to filter bed files according to filtered vcf..."
      cd ${outdir}

      #get a bedfile with the coordinates of processed SVs (VCF file doesnt have end coordinate accessible for bedtools intersect)
      awk 'BEGIN { OFS="\t" } /^#/ {next} !/^#/ {
        split($8,m,";")
        split(m[1],n,"=")
        print $1,$2,n[2] }' "${prx}_filtered1.sv.vcf" > filtered_coordinates.bed

      #intersect the path bedfiles with filtered coordinates to get only the SVs that are valid
      bedtools intersect -F 1 -wa -a "${prx}_primcall.bed" -b filtered_coordinates.bed  > "${prx}_primcall_filtered.bed" && \
      bedtools intersect -F 1 -wa -a "${prx}_altcall.bed" -b filtered_coordinates.bed > "${prx}_altcall_filtered.bed" && \
      bedtools intersect -F 1 -wa -a "${prx}_coastcall.bed" -b filtered_coordinates.bed > "${prx}_coastcall_filtered.bed" && \
      bedtools intersect -F 1 -wa -a "${prx}_unfiltered.bed" -b filtered_coordinates.bed > "${prx}_filtered.bed"

      if [[ $? -eq 0 ]] ; then
        echo "[M]: Done."
      else
        echo "[E]: Filtering of bed files failed. Exit code $?"
        exit 1
      fi

    else
      echo "[E]: Conversion of merged bed file to VCF failed. Exiting code $?"
      exit 1
    fi
  else
    echo "[E]: Merging of bed files failed. Exit code $?"
    exit 1
  fi
else
  echo "[E]: Path bed files not found in temp directory. Exiting."
  exit 1
fi
