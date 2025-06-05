#!/bin/bash

if [[ ( $@ == "--help") ||  $@ == "-h" ]]
then
  echo "Usage: ./minimap2.sh -t <THREADS> -s <THREADS> -r <REF.FA> -q <HIFI.FASTQ.GZ> -o <OUT.bam>"
  echo ""
  echo "Dependencies:"
  echo "    minimap2"
  echo "    samtools"
  echo ""
  echo "Arguments:"
  echo "-t <THREADS>         No. of threads for minimap2. Default 3."
  echo "-s <THREADS>	     No. of threads for sorting. Default 1."
  echo "-r <REF.FA>          Path to the reference genome."
  echo "-q <HIFI.FASTQ.GZ>   Path to PacBio HiFi reads."
  echo "-o <OUT>             BAM file name to output to, including path."
  echo "Note kmer length is internally set to 18." 
  echo ""
  exit 0
fi

thr_mini=3
thr_sort=1
OPTSTRING="t:s:r:q:o:"
while getopts ${OPTSTRING} opt
do
  case ${opt} in
    t) thr_mini=${OPTARG};;
    s) thr_sort=${OPTARG};;
    r) ref=${OPTARG} ;;
    q) reads=${OPTARG} ;;
    o) out=${OPTARG} ;;
  esac
done

if [[ -z "$ref" || -z "$reads" || -z "$out" ]] ; then
  echo "[E]: All parameters require arguments."
  echo "[E]: Run ./minimap2_hifi.sh --help for detailed usage."
  exit 1
fi

outdir=$(dirname "$out")
refb=$(basename "$ref")
reab=$(basename "$reads")

echo "[M]: Beginning minimap alignment of ${reab} to reference genome ${refb}"

minimap2 -ax map-pb --split-prefix "${outdir}/minitmp" -t "$thr_mini" -k 19 "$ref" "$reads" | \ 
  samtools sort -@ "$thr_sort" -m 4G -T "$outdir" -O bam -o "$out"

if [[ $? -eq 0 ]] ; then
  echo ""
  echo "[M]: Alignment complete."
  exit 0
else
  echo ""
  echo "[E]: Alignment failed. Exiting 1."
  exit 1
fi
  
