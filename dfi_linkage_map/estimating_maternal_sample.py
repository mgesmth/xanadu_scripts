#!/usr/bin/env python
# coding: utf-8

# In[1]:


import sys

if __name__ == "__main__":
    vcf=sys.argv[1]


# In[9]:


required_geno1=[[0,0],[1,1]]
required_geno2=[[1,1],[0,0]]


# In[81]:


p1_count=0
p2_count=0

with open(in_vcf) as f:
    for line in f:
        if line.startswith("#") == True:
            if line.startswith("#CHROM") == True:
                fields=line.strip().split('\t')
                info=fields[0:9]
                samples=[field for field in fields if field not in info]
                p1_i=[i for i,sample in enumerate(samples) if "libP1" in sample][0]
                p2_i=[i for i,sample in enumerate(samples) if "libP2" in sample][0]
                mgs_i=[i for i,sample in enumerate(samples) if i not in [p1_i,p2_i]]
                continue
            else:
                continue
        else:

            fields=line.strip().split('\t')
            info=fields[0:9]
            samples=[field for field in fields if field not in info]
            p1=samples[p1_i]
            p2=samples[p2_i]

            if p1.split(":")[3] == ".":
                p1_gq=0
            else:
                p1_gq=int(p1.split(":")[3])
            if p2.split(":")[3] == ".":
                p2_gq=0
            else:
                p2_gq=int(p2.split(":")[3])

            if p1_gq >= 20 and p2_gq >= 20:

                if "|" in p1.split(":")[0]:
                    p1_geno=set(p1.split(":")[0].split("|"))
                elif "/" in p1.split(":")[0]:
                    p1_geno=set(p1.split(":")[0].split("/"))

                if "|" in p2.split(":")[0]:
                    p2_geno=set(p2.split(":")[0].split("|"))
                elif "/" in p2.split(":")[0]:
                    p2_geno=set(p2.split(":")[0].split("/"))

                if [p1_geno,p2_geno] == [{'1'},{'0'}] or [p1_geno,p2_geno] == [{'0'},{'1'}]:
                    if str(list(p1_geno)[0]) == '0':
                        ref_parent="p1"
                        alt_parent="p2"
                    else:
                        ref_parent="p2"
                        alt_parent="p1"

                    mgs=[sample for i,sample in enumerate(samples) if i in mgs_i]
                    mg_genos=[]
                    for mg in mgs:
                        if mg.split(":")[3] == ".":
                            mg_gq=0
                        else:
                            mg_gq=int(mg.split(":")[3])

                        if mg_gq >= 20:
                            mg_genos.append(mg.split(":")[0])
                        else:
                            continue

                    ref_count=len([geno for geno in mg_genos if geno == '0'])
                    alt_count=len([geno for geno in mg_genos if geno == '1'])

                    if ref_count > alt_count:
                        if alt_count/ref_count > 0.2:
                            raise ValueError(f"Unusually high amount of non-maternal alleles: {ref_count,alt_count}")
                        if ref_parent == "p1":
                            p1_count+=1
                        else:
                            p2_count+=1
                    elif ref_count < alt_count:
                        if ref_count/alt_count > 0.2:
                            raise ValueError(f"Unusually high amount of non-maternal alleles: {ref_count,alt_count}")
                        if alt_parent == "p1":
                            p1_count+=1
                        else:
                            p2_count+=1
                    else:
                        raise ValueError(f"Neither allele count was found to be larger: {ref_count},{alt_count}")
                else:
                    continue

            else:
                continue
print(f"P1 Count: {p1_count}")
print(f"P2 Count: {p2_count}")
