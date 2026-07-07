#!/bin/env python

#get marker info, save to a tmp file (need passed marker count for first couple lines)

import sys
import os

if __name__ == "__main__":
    vcf=sys.argv[1]
    txt=sys.argv[2]
    interval=int(sys.argv[3])

txt_tmp=txt.removesuffix(".txt") + ".tmp"
outdir=os.path.dirname(txt)

heterozygote={1,0}
marker_counter=0
passed_counter=0
prev_chrom="dummy"

with open(vcf) as f, open(txt_tmp, "w") as of:
    for line in f:
        if line.startswith("#") == True:
            if line.startswith("#CHROM") == True:
                header=line.strip().split("\t")
                #sample names start at field 10
                info=header[0:9]
                samples=[field for field in header if field not in info]
                pat=[sample for sample in samples if "libP2" in sample][0]
                pat_i=[i for i,sample in enumerate(samples) if "libP2" in sample][0]
                samples_nopat=[sample for sample in samples if sample != pat]
                mat=[sample for sample in samples_nopat if "libP1" in sample][0]
                mat_i=[i for i,sample in enumerate(samples_nopat) if "libP1" in sample][0]


            else:
                continue
        else:
            marker_counter+=1
            fields=line.strip().split('\t')
            info=fields[0:9]
            chrom=info[0]
            pos=int(info[1])
            x=[field for field in fields if field not in info]
            #exclude paternal genotype
            all_genos=[geno for i,geno in enumerate(x) if i != pat_i]
            mat=all_genos[mat_i]
            mg_genos=[field for i,field in enumerate(all_genos) if i != mat_i]

            if "|" in mat.split(":")[0]:
                mat_geno=set(mat.split(":")[0].split("|"))
            elif "/" in mat.split(":")[0]:
                mat_geno=set(mat.split(":")[0].split("/"))

            if len(mat_geno) == 1:
                #if the marker is homozygous
                continue

            if chrom != prev_chrom:
                #we've reached a new chromosome (includes the first marker)
                marker_type="D1.11"
                #now get mg genotypes
                seg_genos=[]
                for mg in mg_genos:
                    mg_geno=mg.split(":")[0]
                    if mg_geno == ".":
                        seg_genos.append("-")
                    elif mg_geno == "0":
                        seg_genos.append("a")
                    elif mg_geno == "1":
                        seg_genos.append("b")
                    else:
                        raise ValueError(f"[E]: Megagametophyte genotype not recognized for marker {marker_counter}")

                #ANDDDD put it all together
                marker_name="*" + fields[0] + "_" + fields[1]
                segs=[",".join(map(str,seg_genos))]
                newline=[marker_name,marker_type] + segs
                passed_counter+=1
                of.write(" ".join(map(str,newline)) + '\n')
                prev_chrom=chrom
                prev_pos=pos
            else:
                #we are in the same chromosome
                diff=pos-prev_pos
                if diff >= interval:
                    marker_type="D1.11"
                    #now get mg genotypes
                    seg_genos=[]
                    for mg in mg_genos:
                        mg_geno=mg.split(":")[0]
                        if mg_geno == ".":
                            seg_genos.append("-")
                        elif mg_geno == "0":
                            seg_genos.append("a")
                        elif mg_geno == "1":
                            seg_genos.append("b")
                        else:
                            raise ValueError(f"[E]: Megagametophyte genotype not recognized for marker {marker_counter}")

                    #ANDDDD put it all together
                    marker_name="*" + fields[0] + "_" + fields[1]
                    segs=[",".join(map(str,seg_genos))]
                    newline=[marker_name,marker_type] + segs
                    passed_counter+=1
                    of.write(" ".join(map(str,newline)) + '\n')
                    prev_chrom=chrom
                    prev_pos=pos
                else:
                    #marker is too close to previous marker
                    continue

##write necessary header
global num_mg
global mgs
with open(vcf) as f:
    for line in f:
        if line.startswith("#") == False:
            continue
        elif line.startswith("#CHROM") == True:
            header=line.strip().split("\t")
            info=header[0:9]
            samples=[field for field in header if field not in info]
            num_mg=len([sample for sample in samples if "_libP" not in sample])
            mgs=[sample for sample in samples if "_libP" not in sample]
            continue
        else:
            continue

with open(txt_tmp) as f, open(txt,"w") as of:
    line1=[num_mg,passed_counter,0]
    of.write(" ".join(map(str,line1)) + '\n')
    for line in f:
        of.write(line.strip() + '\n')

os.remove(txt_tmp)
print(f"[M]: Done! Passed {passed_counter} markers.")

##DONE!
