#!/bin/bash

module load seqkit/2.8.1
cd /core/projects/EBP/smith/eviann/eviann_int_allvdata

#Step 1: remove pseudogenes and lncRNAs from GFF and peptide sequences
##as an example, the interior genome, but also done for coastal

#first sort
grep "#" interior_primary_mancur_masked_500kb.pseudo_label.allvdata.gff > interior_primary_mancur_masked_500kb.pseudo_label.allvdata.s.gff
for i in $(grep -v "#" interior_primary_mancur_masked_500kb.pseudo_label.allvdata.gff | cut -f1 | sed 's/scaffold_//g' | sort -g | uniq) ; do
  grep -w "scaffold_${i}" interior_primary_mancur_masked_500kb.pseudo_label.allvdata.gff >> interior_primary_mancur_masked_500kb.pseudo_label.allvdata.s.gff
done

grep -v "pseudogene" interior_primary_mancur_masked_500kb.pseudo_label.allvdata.s.gff > interior_primary_mancur_masked_500kb.no_pseudogene.s.gff

#get pseudogene features
grep "#" interior_primary_mancur_masked_500kb.pseudo_label.allvdata.gff > interior_primary_mancur_masked_500kb.pseudogenes.s.gff
grep "pseudogene" interior_primary_mancur_masked_500kb.pseudo_label.allvdata.gff >> interior_primary_mancur_masked_500kb.pseudogenes.s.gff
grep -v "#" interior_primary_mancur_masked_500kb.pseudogenes.s.gff | grep -v "mRNA" | wc -l
#matches number of pseudogenes reported by eviann

awk '$3 ~ "mRNA" {
  split($9,m,";")
  split(m[1],n,"=")
  print n[2]
}' interior_primary_mancur_masked_500kb.pseudogenes.s.gff > pseudogene_mrnas.txt

#remove pseudogenes from transcripts
seqkit grep -v -f pseudogene_mrnas.txt interior_primary_mancur_masked_500kb.allvdata.proteins.fa -o interior_primary_mancur_masked_500kb.no_pseudo.proteins.fa

seqkit grep -v -f pseudogene_mrnas.txt interior_primary_mancur_masked_500kb.allvdata.transcripts.fa -o interior_primary_mancur_masked_500kb.no_pseudo.transcripts.fa

#remove lncRNAs from peptide sequence
awk '$3 ~ "lnc_RNA" {
split($9,m,";")
split(m[1],n,"=")
print n[2]}' interior_primary_mancur_masked_500kb.no_pseudogene.s.gff > lncRNAs.txt

seqkit grep -v -f lncRNAs.txt interior_primary_mancur_masked_500kb.no_pseudo.proteins.fa -o interior_primary_mancur_masked_500kb.no_pseudo_lnc.proteins.fa

seqkit grep -v -f lncRNAs.txt interior_primary_mancur_masked_500kb.no_pseudo.transcripts.fa -o interior_primary_mancur_masked_500kb.no_pseudo_lnc.transcripts.fa

grep "#" interior_primary_mancur_masked_500kb.no_pseudogene.s.gff > interior_primary_mancur_masked_500kb.no_pseudogene_lnc.s.gff
grep -v "lncRNA" interior_primary_mancur_masked_500kb.no_pseudogene.s.gff >> interior_primary_mancur_masked_500kb.no_pseudogene_lnc.s.gff


#Step 2: add cds and geneid info to the peptide file so genespace can match to the gff
#interior as example - also done for coastal 
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

#Step 3: make dir structure

cd /core/projects/EBP/smith/genespace
mkdir genomeRepo ; cd genomeRepo
mkdir coastal_genoC
mkfir interior_genoI
cd coastal_genoC
cp ../../../eviann/eviann_coa_allvdata/coastal_masked_500kb.allvdata.no_pseudo_lnc.proteins_withcds_geneid.fa ./peptidesGenoC.fa
cp ../../../eviann/eviann_coa_allvdata/coastal_masked_500kb.allvdata.no_pseudogene_lnc.s.gff ./genesGenoC.gff
cd ../interior_genoI
cp ../../../eviann/eviann_int_allvdata/interior_primary_mancur_masked_500kb.no_pseudo_lnc.proteins_withcds_geneid.fa ./peptidesGenoI.fa
cp ../../../eviann/eviann_int_allvdata/interior_primary_mancur_masked_500kb.no_pseudogene_lnc.s.gff ./genesGenoI.fa
