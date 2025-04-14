#!/bin/bash

#cut -f1 /core/projects/EBP/smith/CBP_assemblyfiles/interior_primary_1Mb.fa.fai > prim_scaffold_list.txt

mkdir byscaffold_matches_coastal
cd byscaffold_matches_coastal
for scaffold in `cat ../prim_scaffold_list.txt` ; do
	#make a directory for each primary scaffold
	mkdir ${scaffold}
	#grep all the lines corresponding to each primary scaffold + the score and alt scaffold in question
	grep -C 1 "${scaffold}" ../coastal_gsalign_noseq.maf > ./"${scaffold}"/"${scaffold}_allcoastal.txt"
	#Make a file to report the number of alignment between the primary scaffold and each aligned alt scaffold
	touch ./"${scaffold}"/countedalignments.txt
	#grab all of the alternate scaffolds that have an alignment with that scaffold to iterate over (awk using . as field sep to get rid of "qry.")
	 for coa in `cut -d " " -f2 ./${scaffold}/${scaffold}_allcoastal.txt | grep "qry" | uniq | awk -F "." '{print $2}'` ; do
		#count is the number of times the alt scaffold aligned to the primary scaffold
		count=`grep "${coa}" ./"${scaffold}"/"${scaffold}_allcoastal.txt" | wc -l`
		#add the name of the alt scaffold and the count to the counted alignments file
		echo -e "${coa}\t${count}" >> ./"${scaffold}"/countedalignments.txt 
		#just create a file containing all the alignments between the primary scaffold and the specific alt scaffold (for scores)
		grep -B 2 "${coa}" ./"${scaffold}"/"${scaffold}_allcoastal.txt" > ./"${scaffold}"/"${scaffold}.${coa}.txt"
	 done 
	sort -gr -k2 ./"${scaffold}"/countedalignments.txt > ./"${scaffold}"/countedalignments_sorted.txt
	rm ./"${scaffold}"/countedalignments.txt
done
