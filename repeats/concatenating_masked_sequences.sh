#!/bin/bash

repeats_dir=/home/FCAM/msmith/repeats_mancur

#Above 1Mb minor scaffolds ----
##scaffold numbers 21-197
cd ${repeats_dir}/above_1Mb

#get scaffolds in right order in an iterator
touch scaffolds_rightorder.txt
for ((i=21 ; i<198 ; i++)) ; do
  echo "interior_primary_mancur_scaffold${i}.fa.masked" >> scaffolds_rightorder.txt
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
for ((i=198 ; i<1798 ; i++)) ; do
  echo "interior_primary_mancur_scaffold${i}.fa.masked" >> scaffolds_rightorder.txt
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

touch scaffolds_rightorder.txt
for ((i=1 ; i<14 ; i++)) ; do
  echo "interior_primary_mancur_scaffold${i}.fa.masked" >> scaffolds_rightorder.txt
done

touch first20_masked.fa
for file in $(cat scaffolds_rightorder.txt) ; do
  cat ${file} >> first20_masked.fa
done

#Concatenate all
cd ..
cat first_20/first20_masked.fa above_1Mb/above1Mb_masked.fa below_1Mb/below1Mb_masked.fa > interior_primary_final_mancur2_masked.fa
