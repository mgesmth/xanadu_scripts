]#!/bin/bash

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

fieldcheck=`awk '/^#/ {print $0} !/^#/ {exit}' "${contacts}" | grep "columns" | grep "frag1"`
if [ -z "$fieldcheck" ] ; then
	if [ -f "${tmpdir}/contacts_corrected.pairs" ]; then
	    echo "-> Original .pairs file not formatted correctly, but corrected temp file was found. Continuing with this file."
	    contacts="${tmpdir}/contacts_corrected.pairs"
	else
	    awk '
	    BEGIN { OFS = "\t" }
	    /^#/ {
    	    if ($0 ~ /^#columns:/) {
        	sub(/pair_type/, "frag1\tfrag2");
        	print;
    	    } else {
        	print;
    	    }
    		next;
	    }	
	    {
    		# Convert + to 0 and - to 1 in fields 6 and 7
    		if ($6 == "+") $6 = 0;
    		else if ($6 == "-") $6 = 1;

    		if ($7 == "+") $7 = 0;
    		else if ($7 == "-") $7 = 1;

    		# Build a list of fields from $1 to $(NF-1)
    		out = $1;
    		for (i = 2; i < NF; i++) {
        	out = out OFS $i;
    	    }
    	    print out, 0, 1;  # This uses OFS="\t" correctly
	    }' "${contacts}" > "${tmpdir}/contacts_corrected.pairs"
	    #reset contacts
	    contacts="${tmpdir}/contacts_corrected.pairs"
	    echo "-> Done."
	fi
else
	echo "-> Pairs file assumed correctly formatted."
fi

#make the .hic file ----
echo "-> Beginning .hic file creation."
java -XX:+UseParallelGC -Xms150G -Xmx300G -jar $JUICER pre -v --threads "${threads}" -t "${tmpdir}" "${contacts}" "${output}.hic" "${chromsizes}"
if [ $? -eq 0 ]; then
echo "-> juicer_tools pre succeeded."
exit 0
else
echo "[E]: juicer_tools pre failed. Exiting."
exit 1
fi 
