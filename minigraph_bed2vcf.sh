#!/bin/bash
#SBATCH -J mg_bed2vcf
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 12
#SBATCH --mem=50G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=meg8130@student.ubc.ca
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

set -e

echo "[M]: Host Name: `hostname`"
module load java/17.0.2
#minigraph
export PATH="/core/projects/EBP/smith/bin/minigraph-0.21:$PATH"
#minigraph_utils
export PATH="/core/projects/EBP/smith/bin/minigraph-0.21/mg-cookbook-v1_x64-linux:$PATH"
k8_dir=/core/projects/EBP/smith/bin/minigraph-0.21/mg-cookbook-v1_x64-linux

#test code

#cd /core/projects/EBP/smith/bin/minigraph-0.21/test/vcf_test && ls *.bed > samples.txt
#merge bedfiles into one
#echo "[M]: Beginning merging of bedfiles..."
#paste *.bed | ${k8_dir}/k8 ${k8_dir}/mgutils.js merge -s samples.txt - | gzip > test_vcf.sv.bed.gz
#if [ $? -ne 0 ] ; then
#  echo "[E]: Merging of path bedfiles failed. Exiting."
#  exit 1
#else
#  echo "[M]: Merging of path bedfiles complete. Beginning vcf formation..."
  #make vcf and send it out of the tmpdir
#  ${k8_dir}/k8 ${k8_dir}/mgutils-es6.js merge2vcf -r0 test_vcf.sv.bed.gz > ../test_vcf.sv.vcf
#  if [ $? -eq 0 ] ; then
#    echo "[M]: VCF creation complete. Beginning cleanup..."
#  else
#    echo "[E]: VCF creation failed. Exiting."
#    exit 1
#  fi
#fi


home=/home/FCAM/msmith
minidir=${home}/svs/minigraph_out

cd $minidir
#make a tmpdir to run in
mkdir tmp
mv scaffold_alternate_path.bed tmp/
mv scaffold_coastal_path.bed tmp/
#mv primary_path.bed tmp/
cd tmp/
#the order of the genomes in this list matters - doing it manually
echo -e "scaffold_coastal_path.bed\nscaffold_alternate_path.bed" > samples.txt

#merge bedfiles into one
echo "[M]: Beginning merging of path bedfiles..."
paste *.bed | ${k8_dir}/k8 ${k8_dir}/mgutils.js merge -s samples.txt - | gzip > all_primscaff1split.sv.bed.gz
if [ $? -ne 0 ] ; then
  echo "[E]: Merging of path bedfiles failed. Exiting."
  exit 1
else
  echo "[M]: Merging of path bedfiles complete. Beginning vcf formation..."
  #make vcf and send it out of the tmpdir
  ${k8_dir}/k8 ${k8_dir}/mgutils-es6.js merge2vcf -r0 all_primscaff1split.sv.bed.gz > ../all_primscaff1split2.sv.vcf
  if [ $? -eq 0 ] ; then
    echo "[M]: VCF creation complete. Beginning cleanup..."
  else
    echo "[E]: VCF creation failed. Exiting."
    exit 1
  fi
fi

#cleanup and remove tmpdir
mv *_path.bed ..
cd .. && rm -r tmp/
if [ $? -eq 0 ] ; then
  echo "[M]: Cleanup complete. Goodbye."
  exit 0
else
  echo "[E]: Cleanup failed. Exiting 1."
  exit 1
fi
