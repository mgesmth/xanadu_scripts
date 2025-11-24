#!/bin/bash

#doing this twice - since some indels will be in the coastal genome, I'm going to create two data bases to compare against, otherwise it may be more likely that interior gene dups will be recognized.

##done for both interior and coastal annotations
#get gene sequences using annotation

cd /core/projects/EBP/smith/eviann/eviann_justint
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
seqkit subseq --bed ../eviann/eviann_justint/int_gene_coord.bed interior_primary_final_mancur2.fa > interior_geneseqs_justint.fa

##repeat for coastal

#get indel variants from sv_cat file
cd ../minigraph
mkdir gene_dup_dir && cd gene_dup_dir
mv ../../manual_curation_files/interior_geneseqs_justint.fa .
awk '{if ($5 ~ "SIMPLE" && $4 != "INV") {print}}' ../svs_categorized.tsv > svs_categorized_justindels.tsv

#split file by Genotype
##in this case, it's not just about which asm has the variant.
##it matters if the asm has the LONGER variant

python ~/scripts/pangenome/gene_dup_analysis/split_svs_byinsgenotype.py


### Just interior test first

module load bedtools/2.31.1

bedtools intersect -F 1 -f 1 -wa -a ../../final_finalpangenome_filtered2.bed -b svs_categorized_intins.tsv > tmp

sed 's/HiC_//g' tmp > final_finalpangenome_justint.bed && rm tmp

#unbreak the scaffolds

head -n11 ../../interior_primary_final_mancur_1Mb.fa.fai | awk '$1 ~ /HiC_scaffold_[0-9]+_1/ { print $2}' > index.tmp
idx=($(cat index.tmp))
touch final_finalpangenome_justint_unbroken.bed
for i in $(seq 1 6) ; do
  length=${idx[$i]}
  add=$(echo $((${length}+200)))
  awk -v i=$i -v add=$add -v OFS="\t" '{
    scaffold=$1
    if (scaffold ~ "scaffold_"i"_1") {
      gsub(scaffold, "scaffold_"i, $1)
      print
    } else if (scaffold ~ "scaffold_"i"_2") {
      gsub(scaffold, "scaffold_"i, $1)
      new_start=$2+add
      new_end=$3+add
      print $1,new_start,new_end,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14
    } else {
      next
    }
  }' final_finalpangenome_justint.bed >> final_finalpangenome_justint_unbroken.bed
done && rm index.tmp

awk -v OFS="\t" '{
  scaffold=$1
  if (scaffold ~ /scaffold_[0-9]+_/){
    next
  } else {
    print
  }
}' final_finalpangenome_justint.bed >> final_finalpangenome_justint_unbroken.bed

#send inserted alleles to separate files for parallel processing
for scaffold in $(cut -f1 ${bed_filt} | uniq) ; do
  grep -w "$scaffold" ${bed_filt} | \
  awk -v scaffold="$scaffold" '{if ($6 == 0) {
    print ">"scaffold"_sv"NR ORS $14
    } else {
    next
    }}' > ${scaffold}_svs.fasta
done


###Build blast db
module load blast/2.15.0
#found an issue where some of the gene records are duplicated for some reason, where one is a regular locus and another is lncRNA - gonna change the headers to hopefully allow both records to stay

awk '{
  if ($0 ~ /^>/) {
    split($1,m,"_")
    print ">scaffold_"m[2]":"$2
  } else {
    print
  }
}' interior_geneseqs_justint.fa > interior_geneseqs_headerfixed.fa

mkdir geneseqdb && cd geneseqdb
makeblastdb -in ../interior_geneseqs_headerfixed.fa -parse_seqids -dbtype nucl -out interior_geneseqs_justint

blastn -db ../geneseqdb/interior_geneseqs_justint -query scaffold_72_svs.fasta -out scaffold_72_svs.fasta.out -outfmt='6 score evalue qseqid qstart qend qlen sstrand sseqid sstart send slen'
