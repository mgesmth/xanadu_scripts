#!/bin/bash

module load seqkit/2.8.1
cd /core/projects/EBP/smith/eviann/eviann_int_allvdata_new

#Step 1: remove pseudogenes and lncRNAs from GFF and peptide sequences
##as an example, the interior genome, but also done for coastal

oriann=interior_primary_mancur_masked_500kb.fa.no_overlap.gff
sortann="${oriann%.gff}.s.gff"
pseuann="${sortann%.s.gff}_pseudo.s.gff"

#first sort
grep "#" $oriann > "${oriann%.gff}.s.gff"
for i in $(grep -v "#" ${oriann} | cut -f1 | sed 's/HiC_scaffold_//g' | sort -g | uniq) ; do
  grep -w "HiC_scaffold_${i}" ${oriann} >> "$sortann"
done

grep -v "pseudogene" ${sortann} > ${pseuann}
grep -v "#" ${pseuann} | grep -v "mRNA" | wc -l

awk '$3 ~ "mRNA" && $9 ~ "pseudo=true"{
  split($9,m,";")
  split(m[1],n,"=")
  print n[2]
}' ${sortann} > pseudogene_mrnas.txt

prots=interior_primary_mancur_masked_500kb.fa.proteins.fasta
prots_nopseudo=interior_primary_mancur_masked_500kb.fa.no_pseudo.proteins.fasta
prots_nopseudolnc=interior_primary_mancur_masked_500kb.fa.no_pseudo_lnc.proteins.fasta
#remove pseudogenes from transcripts
seqkit grep -v -f pseudogene_mrnas.txt ${prots} -o ${prots_nopseudo}

mrnas=interior_primary_mancur_masked_500kb.fa.transcripts.fasta
mrnas_nopseudo=interior_primary_mancur_masked_500kb.fa.no_pseudo.transcripts.fasta
mrnas_nopseudolnc=interior_primary_mancur_masked_500kb.fa.no_pseudo_lnc.transcripts.fasta
seqkit grep -v -f pseudogene_mrnas.txt ${mrnas} -o ${mrnas_nopseudo}

#remove lncRNAs from peptide sequence
awk '$3 ~ "lnc_RNA" {
split($9,m,";")
split(m[1],n,"=")
print n[2]}' ${sortann} > lncRNAs.txt

seqkit grep -v -f lncRNAs.txt ${prots_nopseudo} -o ${prots_nopseudolnc}

seqkit grep -v -f lncRNAs.txt ${mrnas_nopseudo} -o ${mrnas_nopseudolnc}

grep "#" interior_primary_mancur_masked_500kb.no_pseudogene.s.gff > interior_primary_mancur_masked_500kb.no_pseudogene_lnc.s.gff
grep -v "lncRNA" interior_primary_mancur_masked_500kb.no_pseudogene.s.gff >> interior_primary_mancur_masked_500kb.no_pseudogene_lnc.s.gff


#Step 2: add cds and geneid info to the peptide file so genespace can match to the gff
#interior as example - also done for coastal
cds_pep_file=interior_primary_mancur_masked_500kb.fa.no_pseudo_lnc.proteins_withcds.fa
final_pep_file=interior_primary_mancur_masked_500kb.fa.no_pseudo_lnc.proteins_withcds_geneid.fa

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
    fasta_record+=1
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
    split(substr($1,2),m,"-")

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

awk '{
  if ($0 ~ /^>/) {
    #start at 2 to get rid of >
    mrna_name=substr($1,2)
    #split at hyphen; this is what separate mrna and mrna number
    split(mrna_name,m,"-")
    gene_name=m[1]
    print ">ID=" mrna_name,"geneID=" m[1]
  } else {
    print
  }
}' $prots_nopseudolnc > $final_pep_file
