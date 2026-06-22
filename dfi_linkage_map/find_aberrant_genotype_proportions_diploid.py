#!/bin/env python

import pandas as pd
import sys

if __name__ == "__main__":
    vcf=sys.argv[1]
    gq_threshold=int(sys.argv[2])

aberrant_counts={}
total_counts={}
with open(vcf) as f:
    for line in f:
        if line.startswith("#"):
            if line.startswith("#CHROM"):
                fields=line.strip().split("\t")
                info=fields[0:9]
                samples=[field for field in fields if field not in info]
                mat=[samp for samp in samples if "libP1" in samp][0]
                mat_i=[i for i,samp in enumerate(samples) if "libP1" in samp][0]
                mgs=[samp for samp in samples if samp != mat]
                for mg in mgs:
                    aberrant_counts[mg]=0
                    total_counts[mg]=0
                continue
            else:
                continue
        else:
            fields=line.strip().split("\t")
            info=fields[0:9]
            genotypes=[field for field in fields if field not in info]
            mat=genotypes[mat_i]

            if "|" in mat.split(":")[0]:
                mat_geno=set(mat.split(":")[0].split("|"))
            elif "/" in mat.split(":")[0]:
                mat_geno=set(mat.split(":")[0].split("/"))

            #if genotype is heterozygous, pass on it
            if len(mat_geno) > 1:
                continue
            else:
                mat_allele=int(list(mat_geno)[0])
                mg_genos=[geno for i,geno in enumerate(genotypes) if i != mat_i]
                for i,mg in enumerate(mg_genos):
                    gq=int(mg.split(":")[3])
                    #if genotype call is good, compare to maternal allele to see if it has an unlikely genotype
                    if gq >= gq_threshold:
                        total_counts[mgs[i]]+=1
                        if "|" in mg.split(":")[0]:
                            alleles=set(mg.split(":")[0].split("|"))
                        elif "/" in mg.split(":")[0]:
                            alleles=set(mg.split(":")[0].split("/"))
                        else:
                            raise ValueError("[E]: MG genotype sep not recognized.")
                        if len(list(alleles)) > 1:
                            aberrant_counts[mgs[i]]+=1
                            continue
                        else:
                            allele=int(list(alleles)[0])
                            if allele != mat_allele:
                                aberrant_counts[mgs[i]]+=1
                            else:
                                continue

ab_df=pd.DataFrame({'sample' : list(aberrant_counts.keys()),
                    'ab_count' : list(aberrant_counts.values()),
                    'total_count' : list(total_counts.values())})

ab_df['props'] = ab_df['ab_count']/ab_df['total_count']
ab_df.to_csv(f"aberrant_genotypes_bymg_gq{gq_threshold}.tsv",sep="\t", index=False)
