#!/usr/bin/env python

input_outfile="repeatMasker_merged.out"
family="LTR/Gypsy"
threshold=0.75
output_outfile="_".join([input_outfile.split(".")[0],"gypsy"]) + ".out"

with open(input_outfile, "r") as f, open(output_outfile, "w") as of:
    for line in f:
        fields=line.strip().split()

        #write the header out
        if fields[0] == "SW_score":
            of.write('\t'.join(map(str,fields)) + '\n')
        #if there's a better match in that window, skip the line
        elif fields[15] == "T":
            continue
        #if the line is not a 'family' element, skip
        elif fields[10] != family:
            continue
        else:
            #check to see how much coverage there is of the repeat for each record
            repeat_start=int(fields[11].strip("()"))
            repeat_end=int(fields[12].strip("()"))
            bases_covered=repeat_end-repeat_start

            backend_left=int(fields[13].strip("()"))
            if repeat_start == 1:
                frontend_left=0
            else:
                #coordinate is 1-based, so the overhang on the front is the coordinate start minus 1 (because 1 is 0 front overhang)
                frontend_left=repeat_start-1

            bases_left=float(backend_left+frontend_left)
            bases_total=float(bases_left+bases_covered)
            prop_covered=float(bases_covered/bases_total)

            #if the coverage of the element is more than 85%, keep the record; else, write it to the error file
            if prop_covered >= threshold:
                of.write('\t'.join(map(str,fields)) + '\n')
            else:
                ef.write('\t'.join(map(str,fields)) + '\n')
