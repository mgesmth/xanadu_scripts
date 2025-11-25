#!/bin/env python

import sys

if __name__ == "__main__":
    input_outfile=sys.argv[1]
    output_outfile=sys.argv[2]
    threshold=float(sys.argv[3])
    error_file=sys.argv[4]

with open(input_outfile, "r") as f, open(output_outfile, "w") as of, open(error_file, "w") as ef:
    header=["raw_score","e-value","gene_name","gene_start","gene_end","gene_len","gene_prop","sv_name","sv_start","sv_end","sv_len","sv_prop"]
    of.write('\t'.join(header) + '\n')
    ef.write('\t'.join(header) + '\n')
    for line in f:
        fields=line.strip().split()
        #skip alignments when theres a better scoring match overlapping it
        gene_start=int(fields[3].strip("()"))
        gene_end=int(fields[4])
        gene_len=int(fields[5])
        gene_bases_covered=gene_end-gene_start
        gene_prop_covered=float(gene_bases_covered/gene_len)

        #check to see how much coverage there is of the repeat for each record
        sv_start=int(fields[8].strip("()"))
        sv_end=int(fields[9])
        sv_len=int(fields[10])
        if fields[6] == "plus":
            sv_bases_covered=sv_end-sv_start
        elif fields[6] == "minus":
            sv_bases_covered=sv_start-sv_end

        sv_prop_covered=float(sv_bases_covered/sv_len)

        #if the coverage of the insertion is more than 85%, keep the record; else, write it to the error file
        newline=[fields[0],fields[1],fields[2],fields[3],fields[4],fields[5],gene_prop_covered,fields[7],fields[8],fields[9],fields[10],sv_prop_covered]
        if gene_prop_covered >= threshold:
            of.write('\t'.join(map(str,newline)) + '\n')
        else:
            ef.write('\t'.join(map(str,newline)) + '\n')
