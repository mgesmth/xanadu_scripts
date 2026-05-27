#!/bin/bash
#SBATCH -J mitohifi_alt
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 24
#SBATCH --mem=500G
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

if [[ ${genome_query} == "mitochondrion" ]] ; then

  outdir=${home}/mitohifi/mitogenome_alt
  if [[ ! -d ${outdir} ]] ; then
    mkdir ${outdir}
  fi

  cd ${outdir}
  #download closest relative mitogenome
  singularity exec $mitohifi \
    findMitoReference.py --species "Pseudotsuga menziesii" --outfolder .
  relative=$(ls -1 *.gb | sed 's/.gb$//')

  #run mitohifi
  echo -e "`date`: [M]: Beginning mitogenome assembly from assembled contigs.\n"
  singularity exec $mitohifi \
    mitohifi.py -c ${asm} -p ${simil} -f "${relative}.fasta" -g "${relative}.gb" -t 24 -a "plant"

else

  outdir=${home}/mitohifi/chloroplast_alt
  if [[ ! -d ${outdir} ]] ; then
    mkdir ${outdir}
  fi
  cd ${outdir}

  #download closest relative chloroplast genome
  singularity exec $mitohifi \
    findMitoReference.py --type chloroplast --species "Pseudotsuga menziesii" --outfolder .
  relative=$(ls -1 *.gb | sed 's/.gb$//')

  #run mitohifi
  echo -e "`date`: [M]: Beginning chloroplast assembly from assembled contigs.\n"
  singularity exec $mitohifi \
    mitohifi.py -c ${asm} -p ${simil} -f "${relative}.fasta" -g "${relative}.gb" -t 24 -a "plant" -o 10
fi

echo "`date`: [M]: Done."
