#!/bin/env python

import sys

if __name__ == "__main__":
    #unformatted fa.out from RM, with annoying whitespace
    input_outfile=sys.argv[1]
    sv_name=sys.argv[2]
    output_outfile=sys.argv[3]
    error_file=sys.argv[4]

with open(input_outfile, "r") as f, open(output_outfile, "a") as of, open(error_file, "a") as ef:
    for line in f:
        fields=line.strip().split()
        #skip alignments when theres a better scoring match overlapping it
        if len(fields) == 16:
            continue
        elif fields[0] = "SW" || fields[0] = "score":
            continue
        else:
            fields.append(sv_name)
            #check to see how much coverage there is of the repeat for each record
            repeat_start=int(fields[11])
            repeat_end=int(fields[12])
            bases_covered=repeat_end-repeat_start

            backend_left=int(fields[13].strip("()"))
            if repeat_start == 1:
                frontend_left=0
            else:
                #coordinate is 1-based, so the overhang on the front is the coordinate start minus 1 (because 1 is 0 front overhang)
                frontend_left=repeat_start-1

            bases_left=backend_left+frontend_left
            bases_total=bases_left+bases_covered
            prop_covered=bases_covered/bases_total

            #if the coverage of the element is more than 85%, keep the record; else, write it to the error file
            if prop_covered >= 0.85:
                of.write('\t'.join(map(str,fields)) + '\n')
            else:
                ef.write('\t'.join(map(str,fields)) + '\n')
