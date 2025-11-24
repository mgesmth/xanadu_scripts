#!/bin/bash

#doing this twice - since some indels will be in the coastal genome, I'm going to create two data bases to compare against, otherwise it may be more likely that interior gene dups will be recognized.

##done for both interior and coastal annotations
#get gene sequences using annotation

cd /core/projects/EBP/smith/eviann/eviann_int_allvdata
annotation=interior_primary_mancur_masked_500kb.pseudo_label.allvdata.s.gff

awk -v OFS="\t" '$0 ~ /^#/ {next} $3 ~ "gene" {
  split($9,m,";")
  gsub("geneID=","",m[2])
  print $1,$4,$5,m[2],$6,$7,$2,$3,$9}' $annotation > int_gene_coord.bed

#for interior: in the asm, scaffolds start with "HiC_", adding to bed file
mv int_gene_coord.bed int_gene_coord.tmp

awk -v OFS="\t" '{
  print "HiC_"$0
}' int_gene_coord.tmp > int_gene_coord.bed && rm int_gene_coord.tmp

module load seqkit/2.10.0

cd ../../manual_curation_files

#get gene sequences out of assembly
seqkit subseq --bed ../eviann/eviann_int_allvdata/int_gene_coord.bed interior_primary_final_mancur2.fa > interior_geneseqs.fa

##repeat for coastal

#get indel variants from sv_cat file
cd ../minigraph
mkdir gene_dup_dir && cd gene_dup_dir
mv ../manual_curation_files/interior_geneseqs.fa .
awk '{if ($5 ~ "SIMPLE" && $4 != "INV") {print}}' ../svs_categorized.tsv > svs_categorized_justindels.tsv

#split file by Genotype
##in this case, it's not just about which asm has the variant.
##it matters if the asm has the LONGER variant

python ~/scripts/pangenome/gene_dup_analysis/split_svs_byinsgenotype.py 
