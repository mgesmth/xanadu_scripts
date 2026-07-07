#!/usr/bin/env python
# coding: utf-8

# In[57]:


import pandas as pd
import sys
import os

if __name__ == "__main__":
    snp_missingness_tolerance=float(sys.argv[1])
    ind_missingness_tolerance=float(sys.argv[2])
    gq_threshold=float(sys.argv[3])
    in_vcf=sys.argv[4]
    out_vcf=sys.argv[5]

outdir=os.path.dirname(out_vcf)
inds_passed_filter=os.path.join(outdir,f"inds_passed_filter_gq{gq_threshold}.txt")
out_mg_missing=os.path.join(outdir,f"missingness_per_mg_gq{gq_threshold}.tsv")
out_snp_missing=os.path.join(f"missingness_per_snp_gq{gq_threshold}.hist")

# In[61]:


'''
filter by individual first; then filter by missingness
NOTE: This evaluates MG missingness in the SNPs that are potential markers (not all SNPs)
'''
potential_record_counter=0

mg_missingness = {}

with open(in_vcf) as f:
    for line in f:
        #handle header
        if line.startswith("#") == True:
            if line.startswith("#CHROM") == True:
                header=line.strip().split("\t")
                #sample names start at field 10
                info=header[0:9]
                samples=[field for field in header if field not in info]
                #all megagametophyte samples have "mg" in name; parents don't
                #prepare sample names and their indices separately for better access in loop
                mgs=[sample for sample in samples if "mg" in sample]
                mgs_i=[i for i,sample in enumerate(samples) if "mg" in sample]
                mat_i=[i for i,sample in enumerate(samples) if "libP1" in sample][0]
                #initialize a list to contain missingness values
                for mg in mgs:
                    mg_missingness[mg] = 0
                continue
            else:
                continue
        else:
            candidate_snp=line.strip().split('\t')
            genotypes=candidate_snp[9:len(candidate_snp)]
            mat=genotypes[mat_i]

            #get genotype qualities
            if mat.split(":")[3] == ".":
                mat_gq=0
                mat_depth=0
            else:
                mat_gq=float(mat.split(":")[3])
                mat_depth=int(mat.split(":")[2])
            

            #if maternal genotype is less than threshold and depth is less than 3 (won't happen for the maternal)
            if mat_gq < gq_threshold or mat_depth <= 2:
                #don't continue with candidate snp
                continue
            else:
                mat_alleles=[]
                if "/" in mat.split(":")[0]:
                    mat_alleles.extend(mat.split(":")[0].split("/"))
                elif "|" in mat.split(":")[0]:
                    mat_alleles.extend(mat.split(":")[0].split("|"))
                else:
                    raise ValueError("Maternal genotype separator not recognized. SNP: " + total_recordcounter)

            potential_record_counter+=1
            for i,mg_i in enumerate(mgs_i):
                genotype=genotypes[mg_i]
                mg=mgs[i]
                if genotype.split(":")[3] == ".":
                    gq=0
                    allele_depths=[0,0]
                else:
                    gq=float(genotype.split(":")[3])
                    allele_depths=list(map(int,genotype.split(":")[1].split(",")))

                if gq >= gq_threshold and 0 in allele_depths and abs(allele_depths[0]-allele_depths[1]) >= 2:
                    allele=genotype.split(":")[0]
                else:
                    genotypes[mg_i]=".:0,0:.:0:0,0"
                    mg_missingness[mg]+=1

count_list=list(mg_missingness.values())
count_list[:] = [x/potential_record_counter for x in count_list]
mg_missingness_fraction=pd.DataFrame({'mg' : list(mg_missingness.keys()), 'fraction' : count_list})
mg_missingness_fraction.to_csv(out_mg_missing,sep='\t',index=False)


# In[53]:


mg_blacklist = []
mg_keep = []
mg_missingness_fraction=mg_missingness_fraction.reset_index()
for i,row in mg_missingness_fraction.iterrows():
    if row['fraction'] > ind_missingness_tolerance:
        mg_blacklist.append(row['mg'])
    else:
        mg_keep.append(row['mg'])

with open(inds_passed_filter, "w") as f:
    for ind in mg_keep:
        f.write(f"{ind}\n")


# In[63]:


total_record_counter=0
passed_record_counter=0
mat_poor_count=0

with open(in_vcf) as f, open(out_vcf,"w") as of:
    for line in f:
        #handle header
        if line.startswith("#") == True:
            if line.startswith("#CHROM") == True:
                header=line.strip().split("\t")
                #sample names start at field 10
                info=header[0:9]
                samples=[field for field in header if field not in info]
                samples_filt=[sample for sample in samples if sample not in mg_blacklist]
                #create a list of blacklisted indices so we know what to remove in the SNP lines
                blacklist_indices=[i for i,mg in enumerate(samples) if mg in mg_blacklist]

                #all megagametophyte samples have "mg" in name; parent doesn't
                mat_i=[i for i,sample in enumerate(samples_filt) if "libP1" in sample][0]
                #prepare sample names and their indices separately for better access in loop
                mgs=[sample for sample in samples_filt if "mg" in sample]
                mgs_i=[i for i,sample in enumerate(samples_filt) if sample in mgs]

                #write out header line
                new_header=info+samples_filt
                of.write('\t'.join(map(str,new_header)) + '\n')

                #initialize a histogram list to track missingness per snp stats
                #will make it into a DF at the end
                snp_missingness_breaks=[0.01,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9]
                snp_missingness_count=[0,0,0,0,0,0,0,0,0,0]
                continue

            else:
                of.write(line.strip() + '\n')
        else:
            #now begin processing SNPs
            total_record_counter+=1
            candidate_snp=line.strip().split('\t')
            info=candidate_snp[0:9]
            x=[field for field in candidate_snp if field not in info]
            genotypes=[geno for i,geno in enumerate(x) if i not in blacklist_indices]
            mat=genotypes[mat_i]


            #get genotype qualities for mother tree (and for father, to set it to missing if need be)
            if mat.split(":")[3] == ".":
                mat_gq=0
                mat_depth=0
            else:
                mat_gq=float(mat.split(":")[3])
                mat_depth=int(mat.split(":")[2])

            #if maternal genotype is less than threshold
            #don't continue with candidate snp
            if mat_gq < gq_threshold or mat_depth <= 2:
                mat_poor_count+=1
                continue
            else:

                if "/" in mat.split(":")[0]:
                    mat_alleles=set(mat.split(":")[0].split("/"))
                elif "|" in mat.split(":")[0]:
                    mat_alleles=set(mat.split(":")[0].split("|"))
                else:
                    raise ValueError(f"Maternal genotype separator not recognized. Genotype: {mat}")

                missing_count=0
                for i,mg_i in enumerate(mgs_i):
                    genotype=genotypes[mg_i]
                    if genotype.split(":")[3] == ".":
                        gq=0
                        allele_depths=[0,0]
                    else:
                        gq=float(genotype.split(":")[3])
                        allele_depths=list(map(int,genotype.split(":")[1].split(",")))

                    if gq >= gq_threshold and 0 in allele_depths and abs(allele_depths[0]-allele_depths[1]) >= 2:
                        allele=genotype.split(":")[0]
                        if allele not in mat_alleles:
                            #if the genotype is not one of the maternal alleles, set it to missing
                            genotypes[mg_i]=".:0,0:.:0:0,0"
                            missing_count+=1
                    else:
                        genotypes[mg_i]=".:0,0:.:0:0,0"
                        missing_count+=1
                        
                # place missingness for this SNP in the missingness by snp histogram
                for i,high in enumerate(snp_missingness_breaks, start=0):
                    if high == 0.01:
                        low=0
                    else:
                        low=snp_missingness_breaks[i-1]
                    if (missing_count/(100-len(mg_blacklist)) > low and missing_count/(100-len(mg_blacklist)) <= high):
                        snp_missingness_count[i]+=1

                #filter SNP by missingness
                if missing_count/(100-len(mg_blacklist)) > snp_missingness_tolerance:
                    # if there's too many missing genotypes, filter out
                    continue
                else:
                    #SNP passed filter! write line.
                    passed_record_counter+=1
                    filtered_snp=info + genotypes
                    of.write('\t'.join(map(str,filtered_snp)) + '\n')

snp_missingness=pd.DataFrame({'breaks' : snp_missingness_breaks, 'count' : snp_missingness_count})
snp_missingness.to_csv(out_snp_missing, sep="\t", index=False)

print("[M]: Done filtering.")
print(f"[M]: Total SNPs processed: {total_record_counter}")
print(f"[M]: Total SNPs passed: {passed_record_counter}")
print(f"[M]: Maternal total poor-quality genotypes: {mat_poor_count}")
