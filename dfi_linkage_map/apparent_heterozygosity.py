#!/bin/env python

import sys

if "__name__" == __main__:
	file=sys.argv[1]

het_total_mat_hetero=0
homo_total_mat_hetero=0
het_total_mat_homo=0
homo_total_mat_homo=0
mat_hetero=0
mat_homo=0

meg_gq_threshold=10
mat_gq_threshold=20

mg_hetero={}

with open(file) as f:
    for line in f:
        if line.startswith("#"):
            if line.startswith("#CHROM"):
                fields=line.strip().split("\t")
                info=fields[0:9]
                samples=fields[9:]
                mat_i=[i for i,samp in enumerate(samples) if "libP1" in samp][0]
                mgs=[samp for samp in samples if "libP1" not in samp]
                mgs_i=[i for i,samp in enumerate(samples) if "libP1" not in samp]
                for i in mgs_i:
                    mg_hetero[i]=0
                continue
            else:
                continue
        else:
            fields=line.strip().split("\t")
            info=fields[0:9]
            genotypes=fields[9:]
            mat=genotypes[mat_i]
            megs=[geno for i,geno in enumerate(genotypes) if i != mat_i]
            megs_i=[i for i,geno in enumerate(genotypes) if i != mat_i]
            if mat.split(":")[3] == ".":
                mat_gq=0
            else:
                mat_gq=int(mat.split(":")[3])
            if mat_gq >= mat_gq_threshold:
                if "|" in mat.split(":")[0]:
                    mat_geno=set(mat.split(":")[0].split("|"))
                else:
                    mat_geno=set(mat.split(":")[0].split("/"))
                if len(mat_geno) == 2:
                    mat_hetero+=1
                    for i in megs_i:
                        meg=genotypes[i]
                        if meg.split(":")[3] == ".":
                            gq=0
                        else:
                            gq=int(meg.split(":")[3])
                        if gq >= meg_gq_threshold:
                            if "|" in mat.split(":")[0]:
                                meg_geno=set(meg.split(":")[0].split("|"))
                            else:
                                meg_geno=set(meg.split(":")[0].split("/"))
                            if len(meg_geno) > 1:
                                het_total_mat_hetero+=1
                                mg_hetero[i]+=1
                            else:
                                homo_total_mat_hetero+=1
                        else:
                            continue 
                else:
                    mat_homo+=1
                    for meg in megs:
                        if meg.split(":")[3] == ".":
                            gq=0
                        else:
                            gq=int(meg.split(":")[3])
                        if gq >= meg_gq_threshold:
                            if "|" in mat.split(":")[0]:
                                meg_geno=set(meg.split(":")[0].split("|"))
                            else:
                                meg_geno=set(meg.split(":")[0].split("/"))
                            if len(meg_geno) > 1:
                                het_total_mat_homo+=1
                            else:
                                homo_total_mat_homo+=1
                        else:
                            pass
                    
            else:
                continue

print("total maternal heterozygous genotypes: ",mat_hetero)
print("total maternal homozygous genotypes: ",mat_homo)
print("total megagametophyte heterozygous genotypes (mat hetero): ",het_total_mat_hetero)
print("total megagametophyte heterozygous genotypes: (mat homo): ",het_total_mat_homo)
print("total megagametophyte homozgyous genotypes (mat hetero): ",homo_total_mat_hetero)
print("total megagametophyte homozygous genotypes: (mat homo): ",homo_total_mat_homo)

print(mg_hetero)