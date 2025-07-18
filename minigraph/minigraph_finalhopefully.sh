#!/bin/bash
#SBATCH -J minigraph_final
#SBATCH -p himem2
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
minidir=${home}/svs/minigraph_out
prim=${scratch}/interior_primary_bigscaffoldsplit.fa
alt=${scratch}/interior_alternate_1Mb.fa
coast=${scratch}/coastal_1Mb.fa
out_prefix="finalpangenome"
threads="36"
gfa="${minidir}/${out_prefix}.gfa"
k8_dir=${core}/bin/minigraph-0.21/mg-cookbook-v1_x64-linux
misc_dir=$(core}/bin/minigraph-0.21/misc

prim_prefix=$(basename "$prim" | sed 's/.fa//')
alt_prefix=$(basename "$alt" | sed 's/.fa//')
coast_prefix=$(basename "$coast" | sed 's/.fa//')

#programs
export PATH="${core}/bin/minigraph-0.21:$PATH"
export PATH="${core}/bin/minigraph-0.21/mg-cookbook-v1_x64-linux:$PATH"
export PATH="${core}/bin/gfatools:$PATH"

#--------------------

date
echo "[M]: Beginning pangenome construction."
minigraph -cxggs -t "$threads" "$prim" "$alt" "$coast" > "$gfa"
if [[ $? -eq 0 ]] ; then
  date
  echo "[M]: Pangenome construction complete. Moving on to extracting variants and calling paths."
  gfatools bubble "$gfa" > "${minidir}/${out_prefix}.bed"
else
  date
  echo "[E]: Pangenome construction failed. Exiting 1."
  exit 1
fi

#Calling paths in a conditional because I don't trust set -e
minigraph -xasm --call -t "$threads" "$gfa" "$prim" > "${minidir}/${prim_prefix}.bed"
if [[ $? -eq 0 ]] ; then 
  minigraph -xasm --call -t "$threads" "$gfa" "$alt" > "${minidir}/${alt_prefix}.bed"
  if [[ $? -eq 0 ]] ; then
    minigraph -xasm --call -t "$threads" "$gfa" "$coast" > "${minidir}/${coast_prefix}.bed"
    if [[ $? -eq 0 ]] ; then
      echo "[M]: Bubbles popped and paths called. Moving onto VCF file creation."
    else
      echo "[E]: Call coastal path failed. Exit code $?"
      exit 1
    fi
  else
    echo "[E]: Call alternate path failed. Exit code $?"
    exit 1
  fi
else
  echo "[E]: Call primary path failed. Exit code $?"
  exit 1
fi

mkdir ${scratch}/minigraph_tmp
cd ${scratch}/minigraph_tmp
#Get copies of the path files into a temp file so I can run the utils command properly
cp "${minidir}/${prim_prefix}.bed" .
cp "${minidir}/${alt_prefix}.bed" .
cp "${minidir}/${coast_prefix}.bed" .
if [[ -f "${minidir}/${prim_prefix}.bed" && -f "${minidir}/${alt_prefix}.bed" && -f "${minidir}/${coast_prefix}.bed" ]] ; then
  echo -e "${prim_prefix}.bed\n${alt_prefix}.bed\n${coast_prefix}.bed" > samples.txt
  paste *.bed | ${k8_dir}/k8 ${misc_dir}/mgutils.js merge -s samples.txt - | gzip -c > "${out_prefix}.sv.bed.gz"
  if [[ $? -eq 0 ]] ; then
    ${k8_dir}/k8 ${misc_dir}/mgutils-es6.js merge2vcf -r0 "${out_prefix}.sv.bed.gz" > "${minidir}/${out_prefix}.sv.vcf"
    if [[ $? -eq 0 ]] ; then
      date
      echo "[M]: SV VCF created. Filtering and cleaning up..."
      #Filtering for missing data then for where all three alleles are the reference allele
      awk '/^#/ {print} !/^#/ && $10 != "." && $11 != "." && $12 != "." {print}' "${minidir}/${out_prefix}.sv.vcf" | \
      awk '/^#/ {print} !/^#/ && $11 ~ /1:1/ || $12 ~ /1:1/ {print}' > "${minidir}/${out_prefix}_filt.sv.vcf"
      #one additional filter at the summary step, bear in mind
      cd ..
      rm -r minigraph_tmp
      exit 0
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
    

