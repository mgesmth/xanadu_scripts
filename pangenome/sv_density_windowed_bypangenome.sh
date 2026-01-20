#!/bin/bash

if [[ ( $@ == "--help") ||  $@ == "-h" ]]
then
    echo ""
    echo "Usage: ./sv_density_windowed_bypangenome.sh -p <PANGENOME.gfa> -f <GENOME.fa.fai> -w <WINDOW_SIZE> -o <OUTPUT>"
    echo ""
    echo "Calculate proportion of pangenome that is off the reference path in windows."
    echo ""
    echo "Requirements:"
    echo "  gfatools"
    echo ""
    echo "-p <PANGENOME.gfa>       Path to the pangenome file (gfa)."
    echo "-f <GENOME.fa.fai>       Path to the fasta index for the reference genome called in pangenome."
    echo "-w <WINDOW_SIZE>         Window size to calculate over. In bp."
    echo "-o <OUTPUT>              Path to output file."
    echo ""
    echo ""
	exit 0
fi

OPTSTRING="p:f:w:o:"
while getopts ${OPTSTRING} opt
do
case ${opt} in
  p) pangenome=${OPTARG};;
  f) fai=${OPTARG};;
  w) window_size=${OPTARG};;
  o) outfile=${OPTARG};;
  ?)
    echo "invalid option: -${opt}"
    exit 1 ;;
  esac
done

if [[ -z ${pangenome} || -z ${fai} || -z ${window_size} ]] ; then
  echo "[E]: All options require arguments. Exiting."
  echo "[E]: Run ./sv_density_windowed_bypangenome.sh -h or --help to see detailed usage."
  exit 1
elif [[ -z ${outfile} ]] ; then
  window_size_hr="$(echo $((${window_size}/1000000)))Mb"
  outfile="sv_density_${window_size_hr}.tsv"
fi

#all windows will be in Mb
window_size_hr="$(echo $((${window_size}/1000000)))Mb"

touch ${outfile}

for scaffold in $(cut -f1 ${fai}) ; do
  echo "`date`:[M]: Beginning calculations for ${scaffold}"
  #get length of the scaffold
  len=$(grep -w "$scaffold" ${fai} | cut -f2)
  #get the number of records that will be passed to awk, so we can control the last record
  num_windows=$(seq 1 ${window_size} ${len} | wc -l)
  #create index with scaffold name, start and end of each XMb window
  seq 1 ${window_size} ${len} | awk -v ws="$window_size" -v scaff="$scaffold" -v len="$len" -v nw="$num_windows" -v OFS="\t" '{
    if (NR < nw) {
      window_end=$1+(ws-1)
      print scaff,$1,window_end
    } else {
      print scaff,$1,len
    }
  }' > "${scaffold}_${window_size_hr}.idx"

  for window in $(cat "${scaffold}_${window_size_hr}.idx") ; do
    #scaffold name
    sc=$(echo "$window" | cut -f1)
    #start of window
    st=$(echo "$window" | cut -f2)
    #end of window
    en=$(echo "$window" | cut -f3)
    #extract pangenome in ech window
    gfatools view -R "${sc}:${st}-${en}" ${pangenome} > "${window}.gfa"
    #get stats on sub-pangenome, store proportion of non-rank-0 sequence
    prop=$(gfatools stat "tmp.gfa" | awk '{
      if ($1 ~ "Total") {
        total=$4
      } else if ($1 ~ "Sum") {
        rank_zero=$6
        print 1-(rank_zero/total)
        exit
      }
    }')

    #add data on this window to output file
    echo -e "${sc}\t${st}\t${en}\t${prop}" >> sv_density_${window_size_hr}.tsv
    rm tmp.gfa
    echo "`date`:[M]: Complete calculations for ${scaffold}"
  done && rm "${scaffold}_${window_size_hr}.idx"
done
