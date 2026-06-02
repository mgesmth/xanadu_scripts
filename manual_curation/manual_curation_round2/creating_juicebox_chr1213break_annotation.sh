#!/bin/bash

#the file that contains the coordinates of the most proximal markers between the two scaffold_3 linkage groups
potential_break=~/potential_scaffold3_break.bed 

# get a version of the ${genome}.final_asm.scaffold_track.txt file with just these fragments ----
# from hic map: the new scaffold_3 contains fragments 1,3,5,7,9,13,15,19,21,23,25

awk -F "\t" -v OFS="\t" 'NR==1 { print ; next } $8 ~ "scaffold_3_primary" { 
	if ($8 ~ "scaffold_3_primary:::fragment_11" || $8 ~ "scaffold_3_primary:::fragment_17") {
		#exclude is either of the fragments not included
		next
	} else if ($8 ~ "debris") {
		#or is debris
		next
	} else {
		print
		next
	}
} {
	#if is another scaffold
	next
}' interior_primary_final.final_asm.scaffold_track.txt > scaffold_3_primary.final_asm.scaffold_track.txt

# get a verion of the ${genome}.FINAL.assembly with just the relevant fragments
awk '$1 ~ "scaffold_3_primary" {
	if ($1 ~ "debris") {
		next
	} else if ($1 ~ "fragment_11" || $1 ~ "fragment_17") {
		next
	} else {
		print
		next
	}
}{
	next
}' interior_primary_final.FINAL.assembly > scaffold_3_primary.FINAL.assembly

#from this file we can see that fragment_15 has an "overhang gap"; the lengths of the gaps are removed from the final assembly
#in theory, to construct the final scaffold, we add 200 (for the gap size) between each fragment and subtract the legnths of the gaps from the 
#fragments that have gaps
#let's make sure that math works

# get the total length implied by the .assembly file
implied_len=$(cut -f3 -d " " scaffold_3_primary.FINAL.assembly | paste -sd+ - | bc)
#get the finished scaffold length
final_len=$(head -n3 /core/projects/EBP/smith/final_genome_12/interior_primary_final.FINAL.fasta.fai | tail -n1 | cut -f2)
#get the difference
echo $((${final_len}-${implied_len}))
#number is 1810. There are 11 fragments, which means 10 post-review gaps; 10*200=2000, subtract the one gap in fragment 15 (190) closes the differences!

#Create coordinates that reflect the final scaffold length to shift the potential break coordinate to, then undo
#we need to know what fragment(s) the break maps to to know how many 200Ns to subtract from within the annotation to get it to transfer
awk -F "\t" -v OFS="\t" '{
	if (FNR == 1) {
		#start a variable to track how many bases to add as we go along the scaffold 
		add=0
		gap_check="off"
		#skip header
		next
	} else {
		split($8,m," ")
		split(m[1],n,"_")
		frag_num=n[4]*1
		if (frag_num == 1) {
			#if the first fragment, no gap is added
			start=$9
			end=$10
			asm_start=start-1
		} else if (frag_num == 15) {
			#need to subtract the overhand gap by adjusting the length of the fragment
			add+=200
			start=$9+add
			end=($10-190)+add
			#remove the 190 for future fragments
			add=add-190
		} else {
			add+=200
			start=$9+add
			end=$10+add
		}
		frag=substr($8,2)
		shifted_start=start-asm_start
		shifted_end=end-asm_start
		print frag,start,end,shifted_start,shifted_end
		next
	}		
}' scaffold_3_primary.final_asm.scaffold_track.txt > scaffold_3_primary.fragment_placement.txt


#according to this, the potential break starts in fragment 5 and ends in fragment 13
#this means there are 3 gaps, meaning 600bp that need to be removed from within the region to map properly to the HiC map - end coordinate
#and, there are 2 gaps before the start, meaning start coordinate needs to be moved back 400bp
#finally, both the start and end coordinate need to be translated back to asm format by adding the length of assembly that preceeds the start
#of scaffold_3

awk -F "\t" -v OFS="\t" 'FNR==NR {
	if (FNR==1) {
		add_forasm=$2-1
		next
	} else {
		next
	}
} {
	#adjust start coordinate
	start=$2-400
	#adjust end coordinate
	end=$3-600-400
	#adjust for asm
	$2=start+add_forasm
	$3=end+add_forasm
	print
}' scaffold_3_primary.fragment_placement.txt $potential_break > adjusted_potential_break.bed

#Creating the JUICEBOX 2D annotation

#it would appear the assembly-level records are 8x smaller than the scaffold level records in the ${genome}.scaffold_track.txt file
#by this logic 1 bp in the assembly record is 8 bp in the scaffold record



