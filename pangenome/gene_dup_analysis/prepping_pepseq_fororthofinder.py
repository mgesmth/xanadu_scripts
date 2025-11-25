#!/bin/env python

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
            gene=rna_dict[mrna]
            newline=[x,gene]
            of.write(' '.join(map(str,newline)) + '\n')
        else:
            of.write(line)
