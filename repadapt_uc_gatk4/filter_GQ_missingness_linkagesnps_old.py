#!/bin/env python

import sys

if __name__ == "__main__":
    #unformatted fa.out from RM, with annoying whitespace
    missingness_tolerance=float(sys.argv[1])
    in_vcf=sys.argv[2]
    out_vcf=sys.argv[3]

total_record_counter=0
passed_record_counter=0

with open(in_vcf) as f, open(out_vcf,"w") as of:
    for line in f:
        #handle header
        if line.startswith("#") == True:
            if line.startswith("#CHROM") == True:
                header=line.strip().split("\t")
                #sample names start at field 10
                samples=header[9:len(header)]
                #all megagametophyte samples have "mg" in name; parents don't
                mgs=[(i,sample) for i,sample in enumerate(samples) if "mg" in sample]
                parents=[(i,sample) for i,sample in enumerate(samples) if "mg" not in sample]
                of.write('\t'.join(map(str,header)) + '\n')
                continue
            else:
                of.write(line.strip() + '\n')
        else:
            #now begin processing SNPs
            total_record_counter+=1
            candidate_snp=line.strip().split('\t')
            genotypes=candidate_snp[9:len(candidate_snp)]
            p1=genotypes[parents[0][0]]
            p2=genotypes[parents[1][0]]

            #get genotype qualities
            if p1.split(":")[3] == ".":
                gq1=0
            else:
                gq1=float(p1.split(":")[3])

            if p2.split(":")[3] == ".":
                gq2=0
            else:
                gq2=float(p2.split(":")[3])

            #if either parent genotype is less than 10 GQ
            if gq1 < 10.0 or gq2 < 10.0:
                #don't continue with candidate snp
                continue
            else:

                parent_alleles=[]
                if "/" in p1.split(":")[0]:
                    parent_alleles.extend(p1.split(":")[0].split("/"))
                elif "|" in p1.split(":")[0]:
                    parent_alleles.extend(p1.split(":")[0].split("|"))
                else:
                    raise ValueError("Parent genotype separator not recognized. SNP: " + total_recordcounter)
                if "/" in p1.split(":")[0]:
                    parent_alleles.extend(p2.split(":")[0].split("/"))
                elif "|" in p1.split(":")[0]:
                    parent_alleles.extend(p2.split(":")[0].split("|"))
                else:
                    raise ValueError("Parent genotype separator not recognized. SNP: " + total_recordcounter)


                #if both parents are homozoygous for the same allele, not informative, filter
                if parent_alleles == ['1','1','1','1'] or parent_alleles == ['0','0','0','0']:
                    continue

                #now we filter the MGs in a loop
                #going to count samples so we can exclude the parents as we do

                sample_counter=-1
                missing_count=0
                for genotype in genotypes:
                    sample_counter+=1
                    #if the sample is one of the parents
                    if sample_counter == parents[0][0] or sample_counter == parents[1][0]:
                        continue
                    else:
                        if genotype.split(":")[3] == ".":
                            gq=0
                        else:
                            gq=float(genotype.split(":")[3])
                        if gq < 10:
                            #if GQ is less than 10, set the genotype to missing
                            #this will catch all the genotypes that are already missing
                            genotypes[sample_counter]="./.:0,0:.:0:0,0,0"
                            missing_count+=1
                        else:
                            allele=genotype.split(":")[0]
                            if allele not in parent_alleles:
                                #if the genotype is not one of the parent alleles, set it to missing
                                genotypes[sample_counter]="./.:0,0:.:0:0,0,0"
                                missing_count+=1
                            #else keep MG genotype

                if missing_count/100 > missingness_tolerance:
                    # if there's too many missing genotypes,
                    continue
                else:
                    #SNP passed filter! write line.
                    passed_record_counter+=1
                    filtered_snp=candidate_snp[0:8] + genotypes
                    of.write('\t'.join(map(str,filtered_snp)) + '\n')

print("[M]: Done filtering.")
print(f"[M]: Total SNPs processed: {total_record_counter}")
print(f"[M]: Total SNPs passed: {passed_record_counter}")
