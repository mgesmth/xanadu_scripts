#!/bin/bash

if [[ ( $@ == "--help") ||  $@ == "-h" ]]
then
  echo "./contig2scaffold_general.sh -p <CONTIG2SCAFFOLDPOS.IDX> -i <INFILE> -o <OUTFILE> -f <bed/vcf>"

OPTSTRING="p:i:o:f:"
while getopts ${OPTSTRING} opt
do
    case ${opt} in
      p) index=${OPTARG};;
      i) in=${OPTARG};;
      o) out=${OPTARG};;
      f) fmt=${OPTARG};;
    esac
done

if [[ -z ${index} || -z ${in} || -z ${out} || -z ${fmt} ]] ; then
  echo "Argument not supplied. Exiting."
  exit 1
fi

if [[ "$fmt" == "vcf" ]] ; then
    awk '/^#/ {print}' ${in} > ${out}
    cat ${in} | while read -r rec; do
      add=$(echo "$rec" | cut -f1 | grep -wf - ${index} | cut -f2)
      echo "$rec" | awk -v a="$add" 'BEGIN { OFS="\t" } !/^#/ {
        start=$2
        split($8, m, ";", sepsm)
        split(m[1], n, "=", sepsn)
        end=n[2]
        new_start=start+a
        new_end=end+a
        sub(/END=[0-9]+/, "END=" new_end, $8)
        print $1,new_start,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12 
      }' >> ${out}
    done
  elif [[ "$fmt" == "bed" ]] ; then
    touch ${out}
    cat ${in} | while read -r rec; do
      add=$(echo "$rec" | cut -f1 | grep -wf - ${index} | cut -f2)
      echo "$rec" | awk -v a="$add" 'BEGIN { OFS="\t" } {
        new_start=$2+a
        new_end=$3+a
        print $1,new_start,new_end,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14
      }' >> ${out}
    done
  else
    echo "Format not recognized. Exiting."
    exit 1
fi
      
        
    


    
