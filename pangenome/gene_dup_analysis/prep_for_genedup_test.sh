#!/bin/bash

module load blast/2.13.0

makeblastdb -in interior_primary_mancur_masked_500kb.fa.transcripts.fasta -dbtype nucl -parse_seqids -out transcripts_db

blastn -db transcripts_db/transcripts_db -query HiC_scaffold_1_1_svs.fasta -outfmt "6 qseqid qstart qend qlen sseqid sstart send slen" -out blast_test.out
