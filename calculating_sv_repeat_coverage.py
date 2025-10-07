#!/bin/env python

import sys
import os
import pandas as pd

if __name__ == "__main__":
    rm_outfile=sys.argv[1]
    catalog_file=sys.argv[2]
    out=sys.argv[3]

catalog=pd.read_csv(catalog_file, sep="\t",header=None)
catalog.columns = ["sv","scaffold","segment","inner_outer"]

def handle_sv_assignment(fields, sv_list):
    segment=fields[5]
    sv=catalog[catalog['segment'] == segment]['sv'].tolist()
    if len(sv) == 1:
        #if the segment is involved in more than one sv, i.e., is outer
        sv_num1=sv[0]
        sv_num2=sv[0]
    elif len(sv) == 2:
        sv_num1=sv[0]
        sv_num2=sv[1]
    else:
        raise Exception('[E]: SV list has length greater than 2. Exiting.')


with

with open(rm_outfile) as f, open(out, "w") as of:
    #initialize a segment variable
    segment="x"
    sv="x"
    header_switch=1
    for line in f:
        fields=line.strip().split('\t')
        #write header lines out and handle first entry
        if header_switch == 1:
            if fields[0] == "index":
                of.write('\t'.join(map(str, fields)) + '\n')
            else:
                #this will be entered on the first record line
                #turn header switch off so this loop won't be entered again
                header=0
                segment=fields[5]
                sv=catalog[catalog['segment'] == segment]['sv'].tolist()
        else:


        #if we have moved on to a new segment
        if fields[5] != segment:
            #reset the segment variable
            segment=fields[5]
            #check to see if we are still within the same sv
            current_sv=catalog[catalog['segment'] == segment]['sv'].tolist()
            if current_sv != sv:
                #if not, write out
            current_sv_list=[segment]
