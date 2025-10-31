#!/bin/bash

module load blast/2.13.0

makeblastdb -in interior_primary_mancur_masked_500kb.fa.transcripts.fasta -dbtype nucl -parse_seqids -out transcripts_db

blastn -db transcripts_db/transcripts_db -query HiC_scaffold_1_1_svs.fasta -outfmt "6 qseqid qstart qend qlen sseqid sstart send slen" -out blast_test.out

grep ">" interior_primary_mancur_masked_500kb.fa.transcripts.fasta | cut -f1 -d ' ' | sed 's/>//g' > locus_names.tmp
awk '$3 ~ "mRNA" { print } $3 ~ "lnc_RNA" { print }' interior_primary_mancur_masked_500kb.fa.pseudo_label.gff > search_lines.tmp
touch biotypes.tmp
for locus in $(cat locus_names.tmp) ; do
  awk -v locus="$locus" '{
    #n will be the length of the array m, allowing you to call the last element of the array (will not have consistent lengths)
    n=split($9,m,";")
    search="ID=" locus
    if (m[1] == search) {
      if ($3 == "lnc_RNA") {
        biotype="lnc_RNA"
      } else {
        split(m[n], biotype_field, "=")
        biotype=biotype_field[2]
      }
      print biotype
      exit
    } else {
      next
    }
  }' search_lines.tmp >> biotypes.tmp
done && rm search_lines.tmp
