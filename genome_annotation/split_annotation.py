#!/bin/env python

scaff_idx = {}

with open("split_scaffold_lengths.tsv") as f1:
    for line in f1:
        key, value = line.strip().split("\t")
        if key.endswith("_1"):
            scaff_idx[key]=int(value)
        else:
            continue

with open("gene_coord.tmp") as f2:
    for line in f2:
        fields=line.strip().split("\t")
        unbroken_scaff=fields[0]
        chrnum=int(unbroken_scaff.split("_")[2])

        search_for="HiC_scaffold_" + str(chrnum) + "_1"

        chr_fragone_len=scaff_idx[search_for]

        start=int(fields[1])
        end=int(fields[2])

        if start > end:
            continue

        if end <= chr_fragone_len:
            print("hi")
            #continue
            #fields[0]=search_for
            #print("\t".join(map(str,fields)) + '\n')
        elif end < chr_fragone_len and start > chr_fragone_len:
            continue
        elif start > chr_fragone_len:
            fields[0]="HiC_scaffold_" + str(chrnum) + "_2"
            subt=chr_fragone_len-1
            fields[1]=start-subt
            fields[2]=end-subt
            print("\t".join(map(str,fields)) + '\n')
        else:
            print(line)
            print("error parsing coordinates")
