#!/bin/bash

if [[ ( $@ == "--help") ||  $@ == "-h" ]]
then
    echo "Usage: ./gsalign.sh -t <THREADS> -r <REFERENCE> -q <QUERY> -o <PREFIX>"
    echo ""
    echo "Align two genomes with GSAlign."
    echo ""
    echo "dependencies:"
    echo ""
    echo "    GSAlign/1.0.19"
    echo ""
    echo "positional arguments:"
    echo ""
    echo "-t <THREADS>   Number of threads."
    echo "-r <FASTA>     Reference genome in fasta format."
    echo "-q <QUERY>     Query genome in fasta format."
    echo "-o <PREFIX>    Prefix for output file."
    echo "--aln 	 Output alignment as .aln instead of .maf"
    echo ""
    echo ""
	exit 0
fi

format=1

OPTSTRING="t:r:q:o:f"
while getopts ${OPTSTRING} opt
do
    case ${opt} in
	t) threads="${OPTARG}";;
	r) reference="${OPTARG}";;
	q) query="${OPTARG}";;
	o) out_prefix="${OPTARG}";;
	f) case "${OPTARG}" in
	 maf) format=1 ;;
	 aln) format=2 ;;
	esac ;;
        :)
         echo "option ${OPTARG} requires an argument."
         exit 1
	;;
        ?)
         echo "invalid option: ${OPTARG}"
         exit 1
	;;
    esac
done

GSAlign -t "${threads}" -r "${reference}" -q "${query}" -o "${out_prefix}" -fmt "${format}"
