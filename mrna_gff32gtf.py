#!/bin/env python

import sys
import os

if __name__ == "__main__":
    ingff=sys.argv[1]
    outgtf=sys.argv[2]

with open(ingff) as f, open(outgtf, "w") as of:
    for line in f:
        fields=line.strip().split("\t")
        if fields[2] == "mRNA":
            info=fields[8].split(";")
            gene_id=info[1].split("=")[1]
            transcript_id=info[0].split("=")[1]

            fields[8]=f'gene_id "{gene_id}"; transcript_id "{transcript_id}"'

            of.write('\t'.join(map(str,fields)) + '\n')
        else:
            continue
