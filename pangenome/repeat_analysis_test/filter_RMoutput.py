#!/bin/env python

import sys

if __name__ == "__main__":
    #unformatted fa.out from RM, with annoying whitespace
    input_outfile=sys.argv[1]
    output_outfile=sys.argv[2]
    threshold=sys.argv[3]
    error_file=sys.argv[4]

#we only want to consider transposable elements, as they would be what would be inserted
#allowing unknowns - may examine those later
avoid_features=['Low_complexity','rRNA','Satellite','Simple_repeat']

with open(input_outfile, "r") as f, open(output_outfile, "w") as of, open(error_file, "w") as ef:
    for line in f:
        fields=line.strip().split()
        #skip alignments when theres a better scoring match overlapping it
        if not fields:
            continue
        elif len(fields) == 16:
            continue
        elif fields[0] == "SW":
            continue
        elif fields[0] == "score":
            continue
        elif fields[10] in avoid_features:
            continue
        else:
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
            if prop_covered >= threshold:
                of.write('\t'.join(map(str,fields)) + '\n')
            else:
                ef.write('\t'.join(map(str,fields)) + '\n')
