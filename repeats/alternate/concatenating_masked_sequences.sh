#!/bin/bash
#SBATCH -J cat_masked_seq
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 6
#SBATCH --mem=15G
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

echo `hostname`
set -e

repeats_dir=/home/FCAM/msmith/repeats_alternate

#Above 1Mb minor scaffolds ----
##scaffold numbers 21-197
cd ${repeats_dir}/above_1Mb

#concatenate sequences in the right order
touch above1Mb_masked.fa
for file in $(cat above.txt) ; do
  cat ${file}.masked* >> above1Mb_masked.fa
done

#Below 1Mb minor scaffolds ----
##scaffold numbers 198-1797

cd ${repeats_dir}/below_1Mb

##Some of the minor scaffolds had not repetitive sequence identified, so don't have a ".fa.masked" file. Have to check those
touch below1Mb_masked.fa
for file in $(cat below.txt) ; do
  if [[ -f ${file}.masked* ]] ; then
    #if the masked file exists, add that one
    cat ${file}.masked* >> below1Mb_masked.fa
  else
    cat ${file} >> below1Mb_masked.fa
  fi
done

#Major scaffolds ----
cd ${repeats_dir}/first_20

touch first20_masked.fa
for file in $(cat first_20.txt) ; do
  cat ${file}.masked* >> first20_masked.fa
done

#Concatenate all
cd ..
cat first_20/first20_masked.fa above_1Mb/above1Mb_masked.fa below_1Mb/below1Mb_masked.fa > interior_alternate_masked.fa && rm first_20/first20_masked.fa above_1Mb/above_1Mb_masked.fa below_1Mb/below1Mb_masked.fa
