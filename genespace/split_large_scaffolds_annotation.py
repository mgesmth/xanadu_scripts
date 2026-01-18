#!/bin/env python

'''
This script is to split chrs 1-9 in the Chinese pine genome, as program I'm using
to extract peptide sequences will not parse chromosomes significantly larger than
1 Gb.
'''

import os
import sys

if __name__ == "__main__":
	in_gff=sys.argv[1]
	out_gff=sys.argv[2]

with open(in_gff) as f, open(out_gff, "w") as of:
    for line in f:
        fields=line.strip().split('\t')
        chrnum=int(fields[0][3:])

        if chrnum < 10:
            start=int(fields[3])
            end=int(fields[4])
            if end <= 1000000000:
                fields[0]="chr" + str(chrnum) + "a"
                of.write('\t'.join(map(str,fields)) + '\n')
            elif start > 1000000000:
                fields[3]=start-999999999
                fields[4]=end-999999999
                fields[0]="chr" + str(chrnum) + "b"
                of.write('\t'.join(map(str,fields)) + '\n')
            else:
                print(line)
                raise Exception("[E]: Start and/or end on split chr not parsed correctly.")
        else:
            of.write('\t'.join(map(str,fields)) + '\n')
