#!/bin/bash

if [[ ( $@ == "--help") ||  $@ == "-h" ]]
then
    echo ""
    echo "Usage: ./run_busco.sh -t <THREADS> -i <INFILE> -m <MODE> -l <LINEAGE> -o <OUTPUT>"
    echo ""
    echo "Get BUSCO statistics for an assembly."
    echo ""
    echo "Requirements:"
    echo "  Python"
    echo "  Biopython"
    echo "  BBMap"
    echo "  BLAST"
    echo "  Augustus"
    echo "  HMMer > 3.1"
    echo "  R with ggplot2"
    echo "  BUSCO"
    echo ""
    echo "-t <THREADS>         Threads (default 1)."
    echo "-i <INFILE>          Path to input file (nucleotide or protein fasta)."
    echo "-m <MODE>            Mode to run BUSCO in (one of 'genome', 'proteins', 'transcriptome')."
    echo "-l <LINEAGE>         Lineage DB to run BUSCO with (i.e., embryophyta_odb12)"
    echo "-o <OUTPUT>          A path with an output prefix to assign all output directories and files to."
    echo ""
    echo ""
	exit 0
fi

threads=1

OPTSTRING="t:i:o:m:l:"
while getopts ${OPTSTRING} opt
do
case ${opt} in
  t) threads=${OPTARG};;
  i) infile=${OPTARG};;
  o) output=${OPTARG};;
  m) mode=${OPTARG};;
  l) lineage=${OPTARG};;
  ?)
    echo "invalid option: -${opt}"
    exit 1 ;;
  esac
done

if [[ -z ${infile} || -z ${mode} || -z ${lineage} ]] ; then
  echo "[E]: Options -i, -m, and -l require arguments. Exiting."
  echo "[E]: Run ./run_busco.sh -h or --help to see detailed usage."
  exit 1
fi

basein=`basename ${infile}`
baseout=`basename ${output}`
outdir=`dirname ${output}`

echo "[M]: Beginning ${mode} BUSCO assessment of ${basein} with lineage db ${lineage}." 
busco -c "${threads}" -i "${infile}" -m "${mode}" -f -l "${lineage}" -o "${baseout}" --out_path "${outdir}"
