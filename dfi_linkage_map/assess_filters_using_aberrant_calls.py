#!/bin/env python

import sys
import os
import pandas as pd

if __name__ == "__main__":
	vcf=sys.argv[1]
	gq_threshold=float(sys.argv[2])
	missingness_threshold=float(sys.argv[3])

outdir=os.path.dirname(vcf)
good_outfile=os.path.join(outdir,f"goodsnp_filterprofile.txt")
bad_outfile=os.path.join(outdir,f"badsnp_filterprofile.txt")

mg_missingness={}
mg_badcall={}
mg_totaleval={}
total_recordcounter=0
good_call_counter=0
bad_call_counter=0
eval_call_counter=0

with open(vcf) as f, open(good_outfile,"w") as gof, open(bad_outfile,"w") as bof:
    for line in f:
        if line.startswith("#"):
            if line.startswith("#CHROM"):
                header=line.strip().split("\t")
                #sample names start at field 10
                infor=header[0:9]
                relevant_info=[0,1,5,7]
                info=[infor[i] for i in relevant_info]
                samples=[field for field in header if field not in infor]
                #all megagametophyte samples have "mg" in name; parents don't
                #prepare sample names and their indices separately for better access in loop
                mgs=[sample for sample in samples if "mg" in sample]
                mgs_i=[i for i,sample in enumerate(samples) if "mg" in sample]
                #parents=[(i,sample) for i,sample in enumerate(samples) if "mg" not in sample]
                mat=[sample for i,sample in enumerate(samples) if "libP1" in sample][0]
                mat_i=[i for i,sample in enumerate(samples) if "libP1" in sample][0]
                pat_i=[i for i,sample in enumerate(samples) if "libP2" in sample][0]
                
                #write headers to outfiles
                #info fields, then maternal geno, then mgs
                new_header=["chrom","pos","qual","info",mat]
                new_header.extend(mgs)
                gof.write("\t".join(map(str,new_header)) + "\n")
                bof.write("\t".join(map(str,new_header)) + "\n")
                #initialize a list to contain missingness values
                for mg in mgs:
                    mg_missingness[mg] = 0
                    mg_badcall[mg]=0
                    mg_totaleval[mg]=0
                continue
            else:
                continue
        else:
            total_recordcounter+=1
            candidate_snp=line.strip().split('\t')
            infor=candidate_snp[0:9]
            relevant_info=[0,1,5,7]
            info=[infor[i] for i in relevant_info]
            genotypes=[field for field in candidate_snp if field not in infor]
            mat=genotypes[mat_i]
            mg_genotypes=[geno for i,geno in enumerate(genotypes) if i != mat_i and i != pat_i]

            #get genotype qualities
            if mat.split(":")[3] == ".":
                mat_gq=0
            else:
                mat_gq=float(mat.split(":")[3])
                
            if mat_gq < gq_threshold:
                #don't continue with candidate snp
                continue
            else:
                if "|" in mat.split(":")[0]:
                    mat_geno=set(mat.split(":")[0].split("|"))
                elif "/" in mat.split(":")[0]:
                    mat_geno=set(mat.split(":")[0].split("/"))

                #if genotype is heterozygous, pass on it
                if len(mat_geno) > 1:
                    continue
                else:
                    mat_allele=str(list(mat_geno)[0])
                    #maternal genotype is homozygous, and can be used to identify good/bad genotype calls
                    missing_count=0
                    for i,mg_i in enumerate(mgs_i):
                        genotype=genotypes[mg_i]
                        mg=mgs[i]
                        if genotype.split(":")[3] == ".":
                            gq=0
                        else:
                            gq=float(genotype.split(":")[3])
                        if gq < gq_threshold:
                            #if GQ is less than 10, set the genotype to missing
                            #this will catch all the genotypes that are already missing
                            genotypes[mg_i]=".:0,0:.:0:0,0,0"
                            mg_missingness[mg]+=1
                            missing_count=+1
                        else:
                            #evaluatable
                            pass

                    if missing_count <= missingness_threshold:
                        #loop back over an allocate
                        eval_call_counter+=1
                        bad_count=0
                        for i,mg_i in enumerate(mgs_i):
                            genotype=genotypes[mg_i]
                            mg=mgs[i]
                            if genotype == ".:0,0:.:0:0,0,0":
                                #don't eval if the genotype call is missing
                                pass
                            else:
                                allele=genotype.split(":")[0]
                                mg_totaleval[mg]+=1
                                if allele == mat_allele:
                                    #it's a good call
                                    pass
                                else:
                                    #it's a bad call
                                    mg_badcall[mg]+=1
                                    bad_count+=1

                        if bad_count == 0:
                            #this is a good SNP.
                            good_call_counter+=1
                            row=[*info,mat,*mg_genotypes]
                            gof.write("\t".join(map(str,row)) + '\n')
                        elif bad_count > 3:
                            pass
                            #this is a bad SNP.
                            bad_call_counter+=1
                            row=[*info,mat,*mg_genotypes]
                            bof.write("\t".join(map(str,row)) + '\n')
                        else:
                            continue

print("[M]: Done.")
print(f"[M]: Found {good_call_counter} good SNPs and {bad_call_counter} bad SNPs.")

ab_df=pd.DataFrame({'sample' : list(mg_badcall.keys()),
                    'ab_count' : list(mg_badcall.values()),
                    'total_count' : list(mg_totaleval.values())})

ab_df['props'] = ab_df['ab_count']/ab_df['total_count']
ab_df.to_csv(f"aberrant_genotypes_bymg_stdfilters_gq{gq_threshold}.tsv",sep="\t", index=False)


