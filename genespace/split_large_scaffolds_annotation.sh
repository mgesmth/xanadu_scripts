#!/bin/bash


###This script is to split chrs 1-9 in the Chinese pine genome, as program I'm using
###to extract peptide sequences will not parse chromosomes significantly larger than
###1 Gb.


OPTSTRING="i:o:"
while getopts ${OPTSTRING} opt
do
case ${opt} in
  i) input=${OPTARG};;
  o) output=${OPTARG};;
  ?)
    echo "invalid option: -${opt}"
    exit 1 ;;
  esac
done

awk -F "\t" -v OFS="\t" '{
  chrnum=substr($1,4)*1

  if (chrnum < 10) {
    start=$4*1
    end=$5*1
    if (end <= 1000000000) {
      new_chr="chr" chrnum "a"
      $1=new_chr
      print
    } else if (start > 1000000000) {
      new_start=start-999999999
      new_end=end-999999999
      $4=new_start
      $5=new_end
      new_chr="chr" chrnum "b"
      $1=new_chr
      print
    }
  } else {
    print
  }
}' $input > $output 
