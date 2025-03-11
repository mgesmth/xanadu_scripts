#!/bin/bash

echo `hostname`

module load juicer/

#Directory Structure ---
core=/core/projects/EBP/smith
juicedir=${core}/juicedir
work=${juicedir}/work
scripts=${juicedir}/scripts

#Now we	have .hic file.	Moving on to feature annotation...

#Arrowhead - an	algorithm that finds contact domains, i.e. places where	there is many hic contacts
#this may identify centromeres because they tend to be in close	proximity

#k is the normalization	for the	map. 

cd $work

arrowhead --threads 36 -k KR ??.hic contact_domains_list

   


