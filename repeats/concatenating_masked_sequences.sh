#!/bin/bash
#SBATCH -p general
#SBATCH -q general
#SBATCH -J concatenate_results
#SBATCH -c 8
#SBATCH --mem=16G

set -e

repeats_dir=/home/FCAM/msmith/repeats_round2

#Above 1Mb minor scaffolds ----
cd ${repeats_dir}/above_1Mb

above_scaffnum=$(cat above1Mb.txt | wc -l)

#get scaffolds in right order in an iterator
touch scaffolds_rightorder.txt
for ((i=21 ; i < ${above_scaffnum} ; i++)) ; do
  echo "interior_primary_mancur_scaffold_${i}.fa.masked" >> scaffolds_rightorder.txt
done

#concatenate sequences in the right order
touch above1Mb_masked.fa
for file in $(cat scaffolds_rightorder.txt) ; do
  cat ${file} >> above1Mb_masked.fa
done

#Below 1Mb minor scaffolds ----
##scaffold numbers 198-1797

cd ${repeats_dir}/below_1Mb

touch scaffolds_rightorder.txt
for ((i=$((${above_scaffnum}+1)) ; i<${below_scaffnum} ; i++)) ; do
  echo "interior_primary_mancur_scaffold_${i}.fa.masked" >> scaffolds_rightorder.txt
done

##Some of the minor scaffolds had not repetitive sequence identified, so don't have a ".fa.masked" file. Have to check those
touch below1Mb_masked.fa
for file in $(cat scaffolds_rightorder.txt) ; do
  if [[ -f ${file} ]] ; then
    #if the masked file exists, add that one
    cat ${file} >> below1Mb_masked.fa
  else
    ori_file=${file//.masked/}
    cat ${ori_file} >> below1Mb_masked.fa
  fi
done

#Major scaffolds ----
cd ${repeats_dir}/first_20

cat first20.txt | awk '{
  gsub(".fa","",$1)
  split($1,m,"_")
  gsub(m[5],m[5]*1,$1)
  print $1 ".fa"}' > scaffolds_rightorder.txt

touch first20_masked.fa
for file in $(cat scaffolds_rightorder.txt) ; do
  cat ${file} >> first20_masked.fa
done

#Concatenate all
cd ..
cat first_20/first20_masked.fa above_1Mb/above1Mb_masked.fa below_1Mb/below1Mb_masked.fa > interior_primary_mancur_masked.fa

#concatenate tbl and out files
module load python/3.8.1
python ${repscripts}/process_split_RMoutput.py
