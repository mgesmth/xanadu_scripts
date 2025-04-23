#!/bin/bash

if [[ ( $@ == "--help") ||  $@ == "-h" ]]
then
    echo "Usage: ./make_contact_maps_generate_site_positions.sh -d <TOPDIR> -c <PAIRS> -s <SITE> -g <GENOMEID> -z <GENOMEPATH> -t <THREADS>"
    echo ""
    echo "Build contact maps from unprocessed Hi-C data."
    echo ""
    echo "dependencies:"
    echo ""
    echo "    bwa"
    echo "    python3"
    echo "    juicer"
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
    echo "-x <TMPDIR>      Path to temporary directory for temp files (optional)."
    echo ""
    echo "PLEASE NOTE: some files produced by this script will be very large. Please ensure you have adequate disk space."
    echo ""
    echo ""
	exit 0
fi

chromsizes=""
tmpdir="."

OPTSTRING="t:d:c:s:g:p:y:z:o:x:"
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
	x)
	 tmpdir=${OPTARG};;
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

set errexit

if [ ! -f "${ref}.bwt" ]; then
    echo "-> BWA index not found. Beginning indexing..."
    bwa index ${ref}
    echo "-> Done."
else
    echo "-> BWA index found."
fi


#Generate restriction site files -----
if [ ! -f "${topdir}/restriction_sites/${genome_id}_${site}.txt" ]; then
    echo "-> Restriction site file not found. Running generate_site_positions.py...."
    cd ${topdir}/restriction_sites
    python ${topdir}/scripts/generate_site_positions.py "${site}" "${genome_id}" "${ref}"
    sitefile="${topdir}/restriction_sites/${genome_id}_${site}.txt"
    echo "-> Done."
else
    echo "-> Restriction site file supplied."
    sitefile="${topdir}/restriction_sites/${genome_id}_${site}.txt"
fi

#make the cooler BED version ---
if [ ! -f "${topdir}/restriction_sites/${genome_id}_${site}.bed" ]; then
    echo "-> Restriction bed file not found."
    if [ -f "${topdir}/restriction_sites/${genome_id}_${site}.txt" ]; then
	echo "-> Running awk command..."
    	cd ${topdir}/restriction_sites
    	awk '{
    	    chrom = $1;
    	    for (i = 2; i <= NF; i++) {
        	start = (i == 2) ? 0 : $(i - 1);
        	end = $i;
        	frag_id = i - 2;
        	print chrom "\t" start "\t" end "\t" frag_id;
    	    }
	}' "${sitefile}" > "${topdir}/restriction_sites/${genome_id}_${site}.bed"
	bedsitefile="${topdir}/restriction_sites/${genome_id}_${site}.txt"
    	echo "-> Done."
    else
	echo "[E]: No restriction site file found to manipulate. Exiting."
	exit 1
    fi
else
    echo "-> Restriction bed file found."
    bedsitefile="${topdir}/restriction_sites/${genome_id}_${site}.txt"
fi


#Chromsizes file ----
cd ${topdir}/references

if [ -z "$chromsizes" ]; then
	if [ -f "${sitefile}" ]; then
                echo "-> Chromosome size file note supplied. Creating..."
		awk 'BEGIN{OFS="\t"}{print $1, $NF}' "${sitefile}" > "${genome_id}.chrom.sizes"
                chromsizes="${topdir}/references/${genome_id}.chrom.sizes"
		echo "-> Done."
        else
            	echo "Error: Restriction site file ${sitefile} not found."
                exit 1
        fi
else
	echo "-> Chromosome size file supplied."
fi

#Run pairtools restrict to add fragment sites to the pairs file
pairtools restrict --frags "${bedsitefile}" "${contacts}"
