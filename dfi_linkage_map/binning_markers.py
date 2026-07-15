#!/usr/bin/env python

import sys
import os

if __name__ == "__main__":
    infile=sys.argv[1]
    outfile=sys.argv[2]
    misstol=float(sys.argv[3])

logfile=f"marker_binning_info_miss{misstol}.txt"

def create_repulsion(geno):
    x=["c" if g == "a" else g for g in geno]
    y=["d" if g == "b" else g for g in x]
    z=["b" if g == "c" else g for g in y]
    repul=["a" if g == "d" else g for g in z]
    return(repul)

def potential_crossover(prev_geno,geno):
    check1=geno==prev_geno
    if check1:
        return(False)
    else:
        mismatches=[(a,b) for a,b in zip(geno,prev_geno) if a != "-" and b != "-" and a != b]
        if len(mismatches) == 0:
            #check if mismatches are due to missingness
            #in this case, they are. Let's see how many missing
            missing=[a for a,b in zip(geno,prev_geno) if a == "-" or b == "-"]
            #if the number of missing calls equals or is below the missing tolerance, bin it; if not, keep both
            if len(missing)/100 <= misstol:
                return(False)
            else:
                return(True)
        else:
            #check for repulsion
            repul=create_repulsion(geno)
            check2=repul==prev_geno
            if check2:
                return(False)
            else:
                mismatches=[(a,b) for a,b in zip(repul,prev_geno) if a != "-" and b != "-" and a != b]
                if len(mismatches) == 0:
                    missing=[a for a,b in zip(repul,prev_geno) if a == "-" or b == "-"]
                    if len(missing)/100 <= misstol:
                        return(False)
                    else:
                        return(True)
                else:
                    return(True)


prev_chrom="dummy"
bin_number=1
stage=0
count=-1
with open(infile) as f, open("write.tmp","w") as of, open(logfile,"w") as lf:
    for line in f:
        if stage == 0:
            stage=1
            continue
        elif stage == 1:
            prev_geno=line.strip().split(" ")[2].split(",")
            prev_mark=line.strip().split(" ")[0].split("_")
            stage=2
            continue
        else:
            geno=line.strip().split(" ")[2].split(",")
            mark=line.strip().split(" ")[0].split("_")
            chrom=mark[0][1:]
            prev_chrom=prev_mark[0][1:]
            if chrom == prev_chrom:
                cross=potential_crossover(prev_geno,geno)
                if cross:
                    prev_line=["_".join(prev_mark),"D1.11",",".join(prev_geno)]
                    count+=1
                    of.write(" ".join(prev_line) + '\n')
                    lf.write("\t".join(map(str,[bin_number,"_".join(prev_mark)])) + '\n')
                    bin_number+=1 #we're now in a new bin
                    prev_geno=geno
                    prev_mark=mark
                    stage=2
                    continue
                else:
                    #this is the case where there's no crossover between markers
                    prev_missing=len([g for g in prev_geno if g == "-"])
                    cur_missing=len([g for g in geno if g == "-"])
                    if prev_missing > cur_missing:
                        #if previous marker has more missingness, run with current and drop previous
                        lf.write("\t".join(map(str,[bin_number,"_".join(prev_mark)])) + '\n')
                        prev_geno=geno
                        prev_mark=mark
                        stage=2
                        continue
                    else:
                        #if cur marker has more missingness or they have equal missingness,
                        #keep the prev marker as the prev marker, drop the current
                        lf.write("\t".join(map(str,[bin_number,"_".join(mark)])) + '\n')
                        stage=2
                        continue
            else:
                #we're in a new chr, we need to write out the marker stored as previous
                prev_line=["_".join(prev_mark),"D1.11",",".join(prev_geno)]
                count+=1
                of.write(" ".join(prev_line) + '\n')
                lf.write("\t".join(map(str,[bin_number,"_".join(prev_mark)])) + '\n')
                bin_number+=1
                prev_geno=line.strip().split(" ")[2].split(",")
                prev_mark=line.strip().split(" ")[0].split("_")
                stage=2
                continue

with open("write.tmp") as f, open(outfile,"w") as of:
    header=[100,count,0]
    of.write(" ".join(map(str,header)) + '\n')

    for line in f:
        of.write(line.strip() + '\n')

os.remove("write.tmp")
        