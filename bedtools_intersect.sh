#!/bin/bash


if [[ ( $@ == "--help") ||  $@ == "-h" ]]
then
    echo "Usage: ./bedtools_intersect.sh -a <FEATURES> -b <FEATURES> -f <NUM> -o <OUTPUT>"
    echo ""
    echo "Find overlaps between two sets of genomic features."
    echo ""
    echo "dependencies:"
    echo ""
    echo "    bedtools"
    echo ""
    echo "positional arguments:"
    echo ""
    echo "-a <FEATURES>     A bed/bam/vcf/gff file containing features. Outputs will be written in terms of this file."
    echo "-b <FEATURES      A bed/bam/vcf/gff file containing features OR a .txt file containing a list of files to use."
    echo "-f <NUM>          Minimum overlap required for a hit on A. Default is 1E-9 (1bp)."
    echo "-F <NUM>          Minimum overlap required for a hit on B. Default is 1E-9 (1bp)."
    echo "-o <OUTPUT>       Prefix for output files."
    echo ""
    echo ""
	exit 0
fi

#defaults
f="0.000000001"
F="0.000000001"

OPTSTRING="a:b:f:F:o:"
while getopts ${OPTSTRING} opt
do
    case ${opt} in
	a) a=${OPTARG};;
	b) b=${OPTARG};;
	f) f=${OPTARG};;
  	F) F=${OPTARG};;
	o) output=${OPTARG};;
  ?)
    echo "invalid option: ${opt}"
    exit 1
	;;
    esac
done

if [[ -z ${a} || -z ${b} ]] ; then
  echo "[E]: Parameters -a and -b must have arguments."
  echo "[E]: Run ./bedtools_intersect.sh for detailed usage."
  exit 1
fi

if [[ $b == *.txt ]] ; then
  b_list=$(cat ${b})
  echo ${b_list} | bedtools intersect -a "$a" -b stdin -f "$f" -F "$F" -wa -wb -filenames > ${output}
else
  bedtools intersect -a "$a" -b "$b" -f "$f" -F "$F" -wa -wb > ${output}
fi
