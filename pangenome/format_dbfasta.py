#!/bin/env python
import pandas as pd

with open("interior_primary_mancur_masked_500kb.fa.transcripts.fasta") as fasta, open("locus_names.tmp", "w") as of:
    for line in fasta:
        if ">" in line:
            x=line.strip().split()[0]
            name=x[1:]
            of.write(name + '\n')
        else:
            continue

with open("locus_names.txt") as f, open("interior_primary_mancur_masked_500kb.fa.pseudo_label.gff") as gff, open("biotype.tmp") as of:
    for line in f:
        name 
