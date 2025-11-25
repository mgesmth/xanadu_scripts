#!/bin/env python

#this is necessary because the primary_transcripts.py script, which seeks to find the longest transcript for genes with multiple splice variants, needs a "gene=" with the parent gene to work

int_gff="interior_primary_mancur_masked_500kb.justint.pseudo_label.s.gff"
int_fa="interior_primary_mancur_masked_500kb.justint.proteins.fa"
out_fa="interior_primary_mancur_masked_500kb.justint.proteins_withgenes.fa"

parent_list=[]
rna_list=[]
with open(int_gff) as f:
    for line in f:
        if '#' in line:
            continue
        else:
            fields=line.strip().split('\t')
            info=fields[8].split(";")
            if fields[2] == "mRNA" or fields[2] == "lnc_RNA":
                parent_list.append(info[1].split("=")[1])
                rna_list.append(info[0].split("=")[1])
            else:
                continue

rna_dict={}
for rna, parent in zip(rna_list,parent_list):
    rna_dict[rna] = parent

with open(int_fa) as f, open(out_fa, "w") as of:
    for line in f:
        x=line.strip()
        if x.startswith(">"):
            mrna=x[1:]
            gene="gene=" + rna_dict[mrna]
            newline=[x,gene]
            of.write(' '.join(map(str,newline)) + '\n')
        else:
            of.write(line)

coa_gff="coastal_masked_500kb.justcoa.pseudo_label.gff"
coa_fa="coastal_masked_500kb.justcoa.proteins.fa"
out_fa="coastal_masked_500kb.justcoa.proteins_withgenes.fa"

parent_list=[]
rna_list=[]
with open(coa_gff) as f:
    for line in f:
        if '#' in line:
            continue
        else:
            fields=line.strip().split('\t')
            info=fields[8].split(";")
            if fields[2] == "mRNA" or fields[2] == "lnc_RNA":
                parent_list.append(info[1].split("=")[1])
                rna_list.append(info[0].split("=")[1])
            else:
                continue

rna_dict={}
for rna, parent in zip(rna_list,parent_list):
    rna_dict[rna] = parent

with open(coa_fa) as f, open(out_fa, "w") as of:
    for line in f:
        x=line.strip()
        if x.startswith(">"):
            mrna=x[1:]
            gene="gene=" + rna_dict[mrna]
            newline=[x,gene]
            of.write(' '.join(map(str,newline)) + '\n')
        else:
            of.write(line)
