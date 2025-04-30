#!/bin/bash
 
 if [[ ( $@ == "--help") ||  $@ == "-h" ]]
 then
     echo "Usage: ./minigraph_gfatoolsbbl.sh -t <THREADS> -r <REF.FA/GFA> -q <QUERY1.FA> -o <OUT_PREFIX> [-x <QUERY2.FA> -y <QUERY3.FA> -z <QUERY4.FA>] [-l <CHAINLEN> -k <KMER>]"
     echo ""
     echo "A script to generate a genome alignment graph (GFA) of up to 5 genomes using minigraph."
     echo ""
     echo "positional arguments:"
     echo ""
     echo "-t <THREADS>         Number of threads to use for mapping. Default."
     echo "-r <REF.FA/.GFA>     Path to the reference genome to use in graph generation."
     echo "-q <QUERY1.FA>       Path to the first query genome to be aligned to the reference."
     echo "-o <OUTPUT_PREFIX>   The prefix to the paths of generated graph. "
     echo "-x <QUERY2.FA>       Path to the second query genome to be aligned. Optional."
     echo "-y <QUERY3.FA>       Path to the third query genome to be aligned. Optional."
     echo "-z <QUERY4.FA>       Path to the fourth query genome to be aligned. Optional."
     echo "-l <CHAINLEN>        Minimum chain length to consider. Default 50k."
     echo "-k <KMER>            Minimizer kmer length. Default 19."
     echo ""
     echo ""
 	exit 0
 fi
 
 #Defaults
 chain="50k"
 kmer=19

optstring=":t:r:q:o:k:l:x:y:z:"
q1="" q2="" q3="" q4=""
while getopts ${optstring} opt; do
  case ${opt} in
    t) threads=${OPTARG} ;;
    r) reference=${OPTARG} ;;
    q) q1=${OPTARG} ;;
    x) q2=${OPTARG} ;;
    y) q3=${OPTARG} ;;
    z) q4=${OPTARG} ;;
    o) output_prefix=${OPTARG} ;;
    l) chain=${OPTARG} ;;
    k) kmer=${OPTARG} ;;
    \?) echo "[E]: Invalid option -$OPTARG" >&2; exit 1 ;;
    :) echo "[E]: Option -$OPTARG requires an argument." >&2; exit 1 ;;
  esac
done

queries="${q1} ${q2} ${q3} ${q4}"
queries=$(echo $queries)  # Normalize whitespace
 
 set -o errexit
 set -o pipefail
 
 if [[ -z "${reference}" || -z "${queries}" || -z "${output_prefix}" ]] ; then
   echo "[E]: Options -r, -q, and -o require an argument. Exiting 1."
   echo "[E]: Run ./minigraph.sh -h or --help for detailed usage."
   exit 1
 else
   echo "[M]: Beginning minigraph graph generation on ${threads} threads"
   echo "[M]: Reference genome: ${reference}"
   echo "[M]: Query genome(s): ${queries}"
   echo ""
   minigraph -cxggs -t "${threads}" -l "${chain}" -k "${kmer}" "${reference}" "${queries}" > "${output_prefix}.gfa"
   echo ""
   echo "[M]: Minigraph graph generation complete."
   echo "[M]: Beginning SV extraction with gfatools bubble."
   echo ""
   gfatools bubble "${output_prefix}.gfa" > "${output_prefix}.bed"
   echo ""
   echo "[M]: gfatools bubble SV extraction complete. Exiting 0."
 fi
