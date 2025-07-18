#!/bin/bash
#SBATCH -J minigraph_prep
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 8
#SBATCH --mem=50G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=meg8130@student.ubc.ca
#SBATCH -o minigraph_prep.%j.out
#SBATCH -e minigraph_prep.%j.err

echo `hostname`

if [[ ( $@ == "--help") ||  $@ == "-h" ]]
then
    echo "Usage: ./minigraph_prep.sh [-x]"
    echo ""
    echo "-x    just split primary (reference) genome (default false)"
    echo ""
    exit 0
fi

justprim="false"

OPTSTRING="x"
while getopts ${OPTSTRING} opt
do
    case ${opt} in
	x) justprim="true" ;;
  ?)
    echo "invalid option: ${OPTARG}"
    exit 1
	;;
    esac
done

module load seqkit/2.10.0

home=/home/FCAM/msmith
core=/core/projects/EBP/smith
scratch=/scratch/msmith
alternate=${core}/CBP_assemblyfiles/interior_alternate_1Mb.fa
coastal=${core}/coastal/coastalDF_scaffrenamed_sorted_1Mb.fa
primary=${core}/CBP_assemblyfiles/interior_primary_1Mb.fa


if [[ "${justprim}" == "false" ]] ; then
  mkdir ${scratch}/minigraph_prep
  outdir=${scratch}/minigraph_prep
  mkdir ${home}/GSAlign/primary_index
  cd ${home}/GSAlign/primary_index
  for scaffold in `awk '$2 ~ "scaffold" {print $2}' ../topalignments_alternate.txt | sort -g -t '_' -k 2 | uniq` ; do
    grep "${scaffold}" ../topalignments_alternate.txt | cut -f1 > "${scaffold}_alternate.txt"
    seqkit grep -n -f "${scaffold}_alternate.txt" "${alternate}" > "${outdir}/alternate_fastas/for${scaffold}_alternate.fa"
  done

  for scaffold in `awk '$2 ~ "scaffold" {print $2}' ../topalignments_coastal.txt | sort -g -t '_' -k 2 | uniq` ; do
    grep "${scaffold}" ../topalignments_coastal.txt | cut -f1 > "${scaffold}_coastal.txt"
    seqkit grep -n -f "${scaffold}_coastal.txt" "${coastal}" > "${outdir}/coastal_fastas/for${scaffold}_coastal.fa"
  done
elif [[ "${justprim}" == "true" ]] ; then
  for scaffold in `awk '$2 ~ "scaffold" {print $2}' ${home}/GSAlign/topalignments_alternate.txt ${home}/GSAlign/topalignments_coastal.txt | sort -g -t '_' -k2 | uniq` ; do
    seqkit grep -n "${scaffold}" ${primary} > "${outdir}/primary_fastas/${scaffold}.fa"
  done
else
  exit 1
fi
