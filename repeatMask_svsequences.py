#!/bin/env python

import sys
import os
import pandas as pd
import numpy as np

"""
building a catalog of the SVs essentially so that after RepeatMasker is over I can go back and figure out what SVs are fully or partially transposable elements
"""

if __name__ == "__main__":
    filt_bed=sys.argv[1]
    out_file=sys.argv[2]

with open(filt_bed, "r") as f, open(out_file, "w") as of:
    sv_num=0
    for line in f:
        sv_num+=1
        segments=line.strip().split()[11]
        scaffold=line.strip().split()[0]
        seg_aslist=segments.split(",")

        #"outer" segments repeat in multiple svs, occassionally, so they appear multiple times (i.e., s41 in both sv 2 and 3). So classifying them so the interpretation is easier later
        rep_inner=len(seg_aslist)-2
        io_aslist=np.repeat(["outer","inner","outer"],[1,rep_inner,1])

        #repeat variant and scaffold number as many times as there are segments that belong to that sv
        variant_aslist=np.repeat([sv_num],[len(seg_aslist)])
        scaffold_aslist=np.repeat([scaffold],[len(seg_aslist)])

        df=pd.DataFrame({"variant":variant_aslist, "scaffold":scaffold_aslist, "segment":seg_aslist, "inner_outer":io_aslist})
        for i in range(len(df)):
            out_fields=df.iloc[i].values.flatten().tolist()
            of.write('\t'.join(map(str, out_fields)) + '\n')
