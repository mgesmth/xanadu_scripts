#!/bin/env python

#get marker info, save to a tmp file (need passed marker count for first couple lines)

import sys

if __name__ == "__main__":
    vcf=sys.argv[1]
    raw=sys.argv[2]

raw_tmp=raw.removesuffix(".raw") + ".tmp"

heterozygote={1,0}
marker_counter=0
passed_counter=0

with open(vcf) as f, open(raw_tmp, "w") as of:
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
            x=[field for field in fields if field not in info]
            #exclude paternal genotype
            all_genos=[geno for i,geno in enumerate(x) if i != pat_i]
            mat=all_genos[mat_i]
            mg_genos=[field for i,field in enumerate(all_genos) if i != mat_i]

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

            #ANDDDD put it all together
            marker_name="*" + fields[0] + "_" + fields[1]
            segs=[",".join(map(str,seg_genos))]
            newline=[marker_name,marker_type] + segs
            passed_counter+=1
            of.write(" ".join(map(str,newline)) + '\n')

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

with open(raw_tmp) as f, open(raw,"w") as of:
    line1=[num_mg,passed_counter,0]
    of.write(" ".join(map(str,line1)) + '\n')
    for line in f:
        of.write(line.strip() + '\n')


print(f"[M]: Done! Passed {passed_counter} markers.")

##DONE!
