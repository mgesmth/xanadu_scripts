#!/bin/bash
#SBATCH -J mitohifi
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 1
#SBATCH --mem=1G
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

set -e
echo "`date`: [M]: Host name: `hostname`"
module load singularity/3.9.2

home=/home/FCAM/msmith
core=/core/projects/EBP/smith
scratch=/scratch/msmith
asm=${core}/CBP_assemblyfiles/interior_alternate_less100Mb.fa
mitohifi=${core}/bin/MitoHiFi.sif

if [[ ( $@ == "--help") ||  $@ == "-h" ]]
then
    echo ""
    echo "Usage: ./06.mitohifi.sh -g <GENOME_QUERY> -s <SIMILARITY_PERC>"
    echo ""
    echo "Build the psme_glauca mitogenome or plastid genome from assembled contigs."
    echo ""
    echo "-g <GENOME_QUERY>      <mitochondrion/chloroplast>."
    echo "-s <SIMILARITY_PERC>   Similarity percentage to declare a mitogenomic/plastid contig. Default: 50"
    echo ""
    echo ""
	exit 0
fi

OPTSTRING="g:s:"
while getopts ${OPTSTRING} opt
do
case ${opt} in
  g) genome_query=${OPTARG};;
  s) simil=${OPTARG};;
  ?)
    echo "invalid option: -${opt}"
    exit 1 ;;
  esac
done

if [[ -z ${genome_query} ]] ; then
  echo "`date`: [E]: Option -g requires an argument, one of <mitochondrion/chloroplast>. Exiting."
  echo "$genome_query"
  echo "`date`: [E]: Run ./06.mitohifi.sh -h or --help to see detailed usage."
  exit 1
elif [[ "${genome_query}" != "mitochondrion" || "${genome_query}" != "chloroplast" ]] ; then
  echo "`date`: [E]: Option -g must be one of <mitochondrion/chloroplast>. Exiting."
  echo "`date`: [E]: Run ./06.mitohifi.sh -h or --help to see detailed usage."
  exit 1
fi

if [[ -z ${simil} ]] ; then
  simil=50
fi

echo "`date`: [M]: ${genome_query} has been selected."
echo "`date`: [M]: Downloading most closely related ${genome_query} genome..."
