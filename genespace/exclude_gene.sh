#!/bin/bash

if [[ ( $@ == "--help") ||  $@ == "-h" ]]
then
    echo ""
    echo "Usage: ./exclude_gene.sh -e <FEATURE_NAME> -i <IN_GFF> -m <OUT_GFF>"
    echo ""
    echo "Exclude a chosen gene feature and all sub-features from a gff."
    echo ""
    echo "-e <STRING>          Name of the feature to be excluded (i.e., LOC_000001)."
    echo "-i <INFILE>          Path to input gff file."
    echo "-o <OUTPUT>          Path to output gff file."
    echo ""
    echo ""
	exit 0
fi

OPTSTRING="e:i:o:"
while getopts ${OPTSTRING} opt
do
case ${opt} in
  e) exclude=${OPTARG};;
  i) input=${OPTARG};;
  o) output=${OPTARG};;
  ?)
    echo "invalid option: -${opt}"
    exit 1 ;;
  esac
done

awk -v exclude="$exclude" -F "\t" '{
	if ($3 == "gene") {
		string="ID=" exclude ";"
		where=match($9,string)
		if (where != 0) {
			next
		} else {
			print $0
		}
	} else {
		string="=" exclude "."
		where=match($9,string)
		if (where != 0) {
			next
		} else {
			print $0
		}
	}
}' ${input} > ${output}
