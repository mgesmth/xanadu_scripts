#!/bin/bash

#interior
transcript_file=interior_primary_mancur_masked_500kb.no_pseudo_lnc.transcripts.fa
peptide_file=interior_primary_mancur_masked_500kb.no_pseudo_lnc.proteins.fa
cds_pep_file=interior_primary_mancur_masked_500kb.no_pseudo_lnc.proteins_withcds.fa
final_pep_file=interior_primary_mancur_masked_500kb.no_pseudo_lnc.proteins_withcds_geneid.fa

#transcript and peptide file have the exact same fasta entries, just translated. I want to do it this way rather than just translating using a command line tool because I think the eviann outputted peptides sequences may respect the starting frame of the mrna in question

awk 'FNR==NR {
  # build an associative array based on fasta record numbers (not line record number)
  # using the > as the rec sep messes up the formatting, this is the simpler work around
  if ($0 ~ /^>/ && NR == 1) {
  #while parsing the first header of the transcript file, start counting and store the CDS header info
    fasta_record=1
    cds_array[fasta_record]=$2
    next
  } else if ($0 ~ /^>/ && NR > 1) {
  #add CDS header info to the array corresponding to the fasta record number\
    fasta_record=fasta_record+1
    cds_array[fasta_record]=$2
    next
  } else {
    #dont care about sequence lines
    next
  } 
} {
  #now we move onto the peptide file
  if ($0 ~ /^>/ && FNR==1) {
    #reset record keeper and begin adding in CDS fields from transcript file
    fasta_record=1
    print $0,cds_array[fasta_record]
  } else if ($0 ~ /^>/ && FNR > 1) {
    fasta_record=fasta_record+1
    print $0,cds_array[fasta_record]
  } else {
    #else a sequence line, print as-is
    print
  }
}' $transcript_file $peptide_file > $cds_pep_file

#now add gene id as well - separate cuz that's how I did it fight me

awk '{
  if ($0 ~ /^>/) {
    #start at 2 to get rid of >
    mrna_name=substr($1,2)
    #split at hyphen; this is what separate mrna and mrna number
    split(mrna_name,m,"-")
    gene_name=m[1]
    print ">ID="mrna_name,$2,"geneID="m[1]
  } else {
    print
  }
}' $cds_pep_file > $final_pep_file
