#!/bin/bash

module load seqkit/2.10.0
module load samtools/1.20

#separate the first scaffold
grep -n ">" interior_primary_1Mb.fa | head -n2
#look for the line number of the second header - you want that minus 1
head -n 34557937 interior_primary_1Mb.fa > scaffold1_primary.fa

#create a gap file to search with in seqkit
echo ">gap" > gap.fa
#gaps are 200 Ns long in this asm
printf 'N%.0s' {1..200} >> gap.fa

#the locate function will output forward and reverse complements - we don't care about that, so let's just get forward
seqkit locate -f gap.fa --bed scaffold1_primary.fa | awk '$6 ~ /+/ {print}' > gaps_located.bed

#there are 793 gaps, meaning 794 contigs. Let's split the scaffold in the middle
head -n394 gaps_located.bed | tail -n1 | cut -f3
#After some experimenting, it seems the start coordinate is actually one before the start of the gap - the last real base before the gap. So take that exact number
seqkit subseq -r 1:980285606 scaffold1_primary.fa > scaffold1_primary_1.fa
head -n394 gaps_located.bed | tail -n1 | cut -f4
#The start coordinate of the 395th contig is this ^ plus 1
#the end coordinate is the length of the scaffold (found in interior_primary_final.fa.fai
seqkit subseq -r 980285807:2073476147 scaffold1_primary.fa > scaffold1_primary_2.fa

#change the headers to reflect that the scaffold is split; scaffold_1_primary_1 and scaffold_1_primary_2
sed -i 's/>scaffold_1_primary/>scaffold_1_primary_1/' scaffold1_primary_1.fa 
sed -i 's/>scaffold_1_primary/>scaffold_1_primary_2/' scaffold1_primary_2.fa 

cat scaffold1_primary_1.fa scaffold1_primary_2.fa > interior_primary_scaffold1split.fa

#total number of lines in the asm
total_len=$(wc -l interior_primary_1Mb.fa | cut -d ' ' -f1)
#number of lines for the first scaffold from up ^ there
echo $((${total_len}-34557937))
tail -n 214624271 interior_primary_1Mb.fa | head -n1
#This line ^ is the header of the second scaffold so correct
tail -n 214624271 interior_primary_1Mb.fa >> interior_primary_scaffold1split.fa
#done!!
