#!/bin/env python

import sys

if __name__ == "__main__":
    #unformatted fa.out from RM, with annoying whitespace
    input_outfile=sys.argv[1]
    output_outfile=sys.argv[2]
    threshold=float(sys.argv[3])
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
            #check to see how much coverage there is of the sv insertion for each record
            sv_start=int(fields[5].strip("()"))
            sv_end=int(fields[6])
            sv_bases_covered=sv_end-sv_start

            sv_backend_left=int(fields[7].strip("()"))
            if sv_start == 1:
                sv_frontend_left=0
            else:
                #coordinate is 1-based, so the overhang on the front is the coordinate start minus 1 (because 1 is 0 front overhang)
                sv_frontend_left=sv_start-1

            sv_bases_left=float(sv_backend_left+sv_frontend_left)
            sv_bases_total=float(sv_bases_left+sv_bases_covered)
            sv_prop_covered=float(sv_bases_covered/sv_bases_total)

            #check to see how much coverage there is of the repeat for each record
            repeat_start=int(fields[11].strip("()"))
            repeat_end=int(fields[12])
            repeat_bases_covered=repeat_end-repeat_start

            repeat_backend_left=int(fields[13].strip("()"))
            if repeat_start == 1:
                repeat_frontend_left=0
            else:
                #coordinate is 1-based, so the overhang on the front is the coordinate start minus 1 (because 1 is 0 front overhang)
                repeat_frontend_left=repeat_start-1

            repeat_bases_left=float(repeat_backend_left+repeat_frontend_left)
            repeat_bases_total=float(repeat_bases_left+repeat_bases_covered)
            repeat_prop_covered=float(repeat_bases_covered/repeat_bases_total)

            #if the coverage of the insertion is more than 85%, keep the record; else, write it to the error file
            if sv_prop_covered >= threshold and repeat_prop_covered >= threshold:
                of.write('\t'.join(map(str,fields)) + '\n')
            else:
                ef.write('\t'.join(map(str,fields)) + '\n')
