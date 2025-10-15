#!/bin/env python

import sys
import os

if __name__ == "__main__":
    #unformatted fa.out from RM, with annoying whitespace
    input=sys.argv[1]
    #name of the properly formatted output, without whitespace and without lesser matches
    output=sys.argv[2]

with open("segment_sequences_allout.fa.out", "r") as f, open("segment_sequences_allout_fixed.fa.out", "w") as of:
    for line in f:
        fields=line.strip().split()
        #skip alignments when theres a better scoring match overlapping it
        if len(fields) == 16:
            continue
        else:
            of.write('\t'.join(map(str,fields)) + '\n')
