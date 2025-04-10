#!/bin/bash

if [[ ( $@ == "--help") ||  $@ == "-h" ]]
then
    echo "Usage: ./make_contact_maps_juicertools.sh -d <TOPDIR> -c <PAIRS> -s <SITE> -g <GENOMEID> -z <GENOMEPATH> -t <THREADS>"
    echo ""
    echo "Build contact maps from unprocessed Hi-C data."
    echo ""
    echo "dependencies:"
    echo ""
    echo "    bwa"
    echo "    python3"
    echo "    juicer"
    echo "    juicebox"
    echo ""
    echo "Requires at least 4 cores and 64GB RAM."
    echo ""
    echo "positional arguments:"
    echo ""
    echo "-t <THREADS>     Number of threads."
    echo "-d <TOPDIR>      Top level directory. Must contain ./fastq, which contains Hi-C fastqs or is soft-linked to them and ./restriction_sites."
    echo "-s <SITE>        Restriction enzyme used in library prep."
    echo "-c <PAIRS>       Hi-C contacts in pairs format."
    echo "-g <GENOMEID>    A unique identifier for your genome."
    echo "-z <GENOMEPATH>  Path to the reference genome."
    echo "-p <CHROMSIZES>  Path to chromosome size file (optional)."    
    echo "-o <OUTPUT>      Prefix for output files."
    echo ""
    echo "PLEASE NOTE: some files produced by this script will be very large. Please ensure you have adequate disk space."
    echo ""
    echo ""
	exit 0
fi

chromsizes=""

OPTSTRING="t:d:c:s:g:py:z:o:"
while getopts ${OPTSTRING} opt
do
    case ${opt} in
	t)
	 threads=${OPTARG};;
	d)
	 topdir=${OPTARG};;
	c)
	 contacts=${OPTARG};;
	s)
	 site=${OPTARG};;
	g)
	 genome_id=${OPTARG};;
	p)
	 chromsizes=${OPTARG};;
	z)
	 ref=${OPTARG};;
	o)
	 output=${OPTARG};;
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
    python ${topdir}/scripts/generate_site_positions.py "${site}" "${genome_id}" "${ref}"
    sitefile="${topdir}/restriction_sites/${genome_id}_${site}.txt"
else
    echo "Restriction site file found. Moving on..."
    sitefile="${topdir}/restriction_sites/${genome_id}_${site}.txt"
fi


#Chromsizes file ----
cd ${topdir}/references

if [ -z "$chromsizes" ]; then
	if [ -f "${sitefile}" ]; then
                awk 'BEGIN{OFS="\t"}{print $1, $NF}' "${sitefile}" > "${genome_id}.chrom.sizes"
                chromsizes="${topdir}/references/${genome_id}.chrom.sizes"
        else
            	echo "Error: Restriction site file ${sitefile} not found."
                exit 1
        fi
else
	echo "Chromosome size file supplied."
fi

#make the .hic file ----
java -jar $JUICEBOX -v -f "${sitefile}" "${contacts}" "${output}.hic" "${chromsizes}"
