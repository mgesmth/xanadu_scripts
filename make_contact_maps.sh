#!/bin/bash

if [[ ( $@ == "--help") ||  $@ == "-h" ]]
then
    echo "Usage: ./make_contact_maps.sh -d <TOPDIR> -s <SITE> -g <GENOMEID> -z <GENOMEPATH> -D <SCRIPTS> -t <THREADS>"
    echo ""
    echo "Build contact maps from unprocessed Hi-C data."
    echo ""
    echo "dependencies:"
    echo ""
    echo "    bwa/0.7.17"
    echo "    python/3.8.1"
    echo "    juicer/1.8.9"
    echo ""
    echo "Requires at least 4 cores and 64GB RAM."
    echo ""
    echo "positional arguments:"
    echo ""
    echo "-d <TOPDIR>      Top level directory. Must contain ./fastq, which contains Hi-C fastqs or is soft-linked to them and ./restriction_sites."
    echo "-s <SITE>        Restriction enzyme used in library prep."
    echo "-g <GENOMEID>    A unique identifier for your genome."
    echo "-z <GENOMEPATH>  Path to the reference genome."
    echo "-D <SCRIPTS>     Path to the juicer scripts."
    echo "-t <THREADS>     Number of threads for BWA alignment."
    echo ""
    echo "PLEASE NOTE: partitions and qos specifications are hard-coded into the juicer.sh script to be compatibile with my cluster. This is a deviation from the script available from the Aiden Lab. To find these lines, please grep <general> and <himem>."
    echo ""
    echo ""
	exit 0
fi

OPTSTRING="t:d:s:g:p:y:z:D:"
while getopts ${OPTSTRING} opt
do
    case ${opt} in
	t)
	 threads=${OPTARG};;
	d)
	 topdir=${OPTARG};;
	s)
	 site=${OPTARG};;
	g)
	 genome_id=${OPTARG};;
	p)
	 chromsizes=${OPTARG};;
	z)
	 ref=${OPTARG};;
	D)
	 scripts=${OPTARG};;
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


if [ ! -f "${ref}.bwt" ]; then
    echo "BWA index not found. Beginning indexing..."
    bwa index ${ref}
else
    echo "BWA index found."
fi

#Generate restriction site files -----
if [ ! -f "${topdir}/restriction_sites/${genome_id}_${site}.txt" ]; then
    echo "Restriction site file not found. Running generate_site_positions.py...."
    cd ${topdir}/restriction_sites
    python ${scripts}/generate_site_positions.py "${site}" "${genome_id}" "${ref}"
    sitefile="${topdir}/restriction_sites/${genome_id}_${site}.txt"
else
    echo "Restriction site file found. Moving on..."
    sitefile="${topdir}/restriction_sites/${genome_id}_${site}.txt"
fi

#Chromsizes file ----
cd ${topdir}/references
if [ -f "${sitefile}" ]; then
    awk 'BEGIN{OFS="\t"}{print $1, $NF}' "${sitefile}" > "${genome_id}.chrom.sizes"
    chromsizes="${topdir}/references/${genome_id}.chrom.sizes"
else
    echo "Error: Restriction site file ${sitefile} not found."
    exit 1
fi

#Run Juicer -----
cd ${topdir}

${scripts}/juicer.sh \
-g "${genome_id}" \
-d "${topdir}" \
-s "${site}" \
-p "${chromsizes}" \
-y "${sitefile}" \
-z "${ref}" \
-t "${threads}"


