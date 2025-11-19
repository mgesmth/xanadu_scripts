#!/bin/env python

import sys
import re

if __name__ == "__main__":
    gff=sys.argv[1]

bed=re.sub(".gff",".bed",gff)

with open(gff) as f, open(bed,"w") as of:
    for line in f:
        if "#" in line:
            continue

        fields=line.strip().split('\t')

        #naming all the fields to keep better track of them
        scaffold=fields[0]
        source=fields[1]
        feature=fields[2]
        start=fields[3]
        end=fields[4]
        score=fields[5]
        strand=fields[6]
        frame=fields[7]
        info=fields[8]

        info_fields=info.split(";")
        id=info_fields.split("=")[1]
        label=id + ":" + feature
        
