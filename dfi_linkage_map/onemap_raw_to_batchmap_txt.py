#!/bin/env python

import sys

if __name__ == "__main__":
    om=sys.argv[1]
    bm=sys.argv[2]

count=0
with open(om) as f, open(bm,"w") as of:
    for line in f:
        count+=1
        #sample,marker count line
        if count == 2:
            fields=line.strip().split(" ")
            ind=[0,1,4]
            new=[field for i,field in enumerate(fields) if i in ind]
            of.write(" ".join(map(str,new)) + '\n')
        elif count > 3:
            if line.startswith("*CHROM") == True or line.startswith("*POS") == True:
                continue
            else:
                fields=line.strip().split(" ")
                name=fields[0]
                seg_type=fields[1]
                genos=fields[2:len(fields)]
                comma_genos=",".join(map(str,genos))
                new_line=[name,seg_type,comma_genos]
                of.write(" ".join(map(str,new_line)) + '\n')
        else:
            continue
            
