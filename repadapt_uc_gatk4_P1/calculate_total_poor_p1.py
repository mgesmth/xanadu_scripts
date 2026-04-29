#!/bin/env python

in_vcf="redo_P2_gatk_filtered_pass_biallelic_indels.vcf"
missingness_tolerance=0.4

p1_poor_count=0
total_counter=0
with open(in_vcf) as f:
    for line in f:
        #handle header
        if line.startswith("#") == True:
            if line.startswith("#CHROM") == True:
                header=line.strip().split("\t")
                #sample names start at field 10
                p1=header[9:len(header)]
                continue
            else:
                continue
        else:
            total_counter+=1
            candidate_snp=line.strip().split('\t')
            genotype=candidate_snp[9:len(candidate_snp)][0]

            #get genotype quality
            if genotype.split(":")[3] == ".":
                gq1=0
            else:
                gq1=float(genotype.split(":")[3])

            if gq1 < 20.0:
                p1_poor_count+=1

print(f"Total Count: {total_counter}")
print(f"P2 Poor Count: {p1_poor_count}")
