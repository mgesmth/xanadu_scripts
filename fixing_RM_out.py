#!/bin/env python

with open("segment_sequences_allout.fa.out", "r") as f, open("segment_sequences_allout_fixed.fa.out", "w") as of:
    for line in f:
        fields=line.strip().split()
        #skip alignments when theres a better scoring match overlapping it
        if len(fields) == 16:
            continue
        else:
            of.write('\t'.join(map(str,fields)) + '\n')
