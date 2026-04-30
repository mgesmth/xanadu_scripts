#!/usr/bin/env python
# coding: utf-8

# In[9]:


import pandas as pd
import sys 


# In[5]:


if __name__ == "__main__":
    vcf=sys.argv[1]


# In[15]:


with open(vcf) as f:
    for line in f:
        if line.startswith("#") == True:
            if line.startswith("#CHROM") == True:
                fields=line.strip().split('\t')
                info=fields[0:9]
                samples=[field for field in fields if field not in info]
                mat=[samp for samp in samples if "libP1" in samp][0]
                mat_i=[i for i,samp in enumerate(samples) if "libP1" in samp][0]
                pat=[samp for samp in samples if "libP2" in samp][0]
                pat_i=[i for i,samp in enumerate(samples) if "libP2" in samp][0]
                mgs=[samp for samp in samples if samp not in [mat,pat]]
                aberrant_counts=pd.DataFrame({ 'sample' : mgs, 'ab_count' : [0] * len(mgs), 'total_count' : [0] * len(mgs) })

                continue
            else:
                continue

        else:
            fields=line.strip().split("\t")
            info=fields[0:9]
            genotypes=[field for field in fields if field not in info]
            mat=genotypes[mat_i]
            pat=genotypes[pat_i]

            if mat.split(":")[3] == ".":
                mat_gq=0
            else:
                mat_gq=int(mat.split(":")[3])

            if mat_gq >= 20.0:
                if "|" in mat.split(":")[0]:
                    mat_geno=set(mat.split(":")[0].split("|"))
                elif "/" in mat.split(":")[0]:
                    mat_geno=set(mat.split(":")[0].split("/"))

                #if genotype is heterozygous, pass on it
                if len(mat_geno) > 1:
                    continue
                else:
                    #if it's homozygous, we can use it to calculate an aberrant score 
                    mat_allele=int(list(mat_geno)[0])
                    mg_genos=[geno for i,geno in enumerate(genotypes) if i not in [mat_i,pat_i]]

                    for i,mg in enumerate(mg_genos):
                        if mg.split(":")[3] == ".":
                            gq=0
                        else:
                            gq=int(mg.split(":")[3])

                        #if genotype call is good, compare to maternal allele to see if it has an unlikely genotype
                        if gq >= 20:
                            aberrant_counts.iloc[i,2]+=1
                            allele=int(mg.split(":")[0])
                            if allele != mat_allele:
                                aberrant_counts.iloc[i,1]+=1
                            else:
                                continue


aberrant_counts['props'] = aberrant_counts['ab_count']/aberrant_counts['total_count']
aberrant_counts.to_csv("aberrant_genotypes_bymg.tsv",sep="\t", index=False)

