#!/bin/bash
#SBATCH -p general
#SBATCH -q general
#SBATCH -J concatenate_results
#SBATCH -c 8
#SBATCH --mem=16G

set -e

repeats_dir=$1
repscripts=$2

module load python/3.13.11-gcc-11.4.0-kifh66l
source /home/FCAM/msmith/python_venv/bin/activate

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

below_scaffnum=$(cat below1Mb.txt | wc -l)

touch scaffolds_rightorder.txt
for ((i=$((${above_scaffnum}+21)) ; i<${below_scaffnum} ; i++)) ; do
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

touch first20_masked.fa
for file in $(cat first20.txt) ; do
  cat ${file}.masked >> first20_masked.fa
done

#Concatenate all
cd ..
cat first_20/first20_masked.fa above_1Mb/above1Mb_masked.fa below_1Mb/below1Mb_masked.fa > concatenated_results/interior_primary_mancur_masked.fa

#concatenate tbl and out files
python3 ${repscripts}/process_split_RMoutput.py
