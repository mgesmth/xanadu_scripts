import pandas as pd
import sys

if __name__ == "__main__":
    snp_missingness_tolerance=float(sys.argv[1])
    ind_missingness_tolerance=float(sys.argv[2])
    in_vcf=sys.argv[3]
    out_vcf=sys.argv[4]

inds_passed_filter="inds_passed_filter.txt"
out_mg_missing="missingness_per_mg.tsv"
out_snp_missing="missingness_per_snp.hist"

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
                parents=[(i,sample) for i,sample in enumerate(samples) if "mg" not in sample]

                #initialize a list to contain missingness values
                for mg in mgs:
                    mg_missingness[mg] = 0
                continue
            else:
                continue
        else:
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

            #if both parent genotypes is less than 20 GQ
            if gq1 < 20.0 and gq2 < 20.0:
                #don't continue with candidate snp
                continue
            elif gq1 < 20.0 and gq2 >= 20.0:
                parent_alleles=[]
                if "/" in p2.split(":")[0]:
                    parent_alleles.extend(p2.split(":")[0].split("/"))
                elif "|" in p2.split(":")[0]:
                    parent_alleles.extend(p2.split(":")[0].split("|"))
                else:
                    raise ValueError("Parent genotype separator not recognized. SNP: " + total_recordcounter)
            elif gq1 >= 20.0 and gq2 < 20.0:
                parent_alleles=[]
                if "/" in p1.split(":")[0]:
                    parent_alleles.extend(p1.split(":")[0].split("/"))
                elif "|" in p1.split(":")[0]:
                    parent_alleles.extend(p1.split(":")[0].split("|"))
                else:
                    raise ValueError("Parent genotype separator not recognized. SNP: " + total_recordcounter)
            else:
                #both genotypes are good
                parent_alleles=[]
                if "/" in p1.split(":")[0]:
                    parent_alleles.extend(p1.split(":")[0].split("/"))
                elif "|" in p1.split(":")[0]:
                    parent_alleles.extend(p1.split(":")[0].split("|"))
                else:
                    raise ValueError("Parent genotype separator not recognized. SNP: " + total_recordcounter)
                if "/" in p2.split(":")[0]:
                    parent_alleles.extend(p2.split(":")[0].split("/"))
                elif "|" in p2.split(":")[0]:
                    parent_alleles.extend(p2.split(":")[0].split("|"))
                else:
                    raise ValueError("Parent genotype separator not recognized. SNP: " + total_recordcounter)

            potential_record_counter+=1
            for i,mg_i in enumerate(mgs_i):
                genotype=genotypes[mg_i]
                mg=mgs[i]
                if genotype.split(":")[3] == ".":
                    gq=0
                else:
                    gq=float(genotype.split(":")[3])
                if gq < 20:
                    #if GQ is less than 10, set the genotype to missing
                    #this will catch all the genotypes that are already missing
                    genotypes[mg_i]="./.:0,0:.:0:0,0,0"
                    mg_missingness[mg]+=1
                else:
                    allele=genotype.split(":")[0]
                    if allele not in parent_alleles:
                        #if the genotype is not one of the parent alleles, set it to missing
                        genotypes[mg_i]="./.:0,0:.:0:0,0,0"
                        mg_missingness[mg]+=1
                    #else keep MG genotype; not declared as missing

count_list=list(mg_missingness.values())
count_list[:] = [x/potential_record_counter for x in count_list]
mg_missingness_fraction=pd.DataFrame({'mg' : list(mg_missingness.keys()), 'fraction' : count_list})
mg_missingness_fraction.to_csv(out_mg_missing,sep='\t',index=False)

'''
We now have all our missingness data per individual.
We create a blacklist of individuals who have too many missing genotypes to blacklist them from the final file.
'''

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

total_record_counter=0
passed_record_counter=0
p1_poor_count=0
p2_poor_count=0

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

                #all megagametophyte samples have "mg" in name; parents don't
                parents=[(i,sample) for i,sample in enumerate(samples_filt) if "mg" not in sample]
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
            p1=genotypes[parents[0][0]]
            p2=genotypes[parents[1][0]]

            #get genotype qualities for parents
            if p1.split(":")[3] == ".":
                gq1=0
            else:
                gq1=float(p1.split(":")[3])

            if p2.split(":")[3] == ".":
                gq2=0
            else:
                gq2=float(p2.split(":")[3])

            #if both parent genotypes are less than 20 GQ
            #don't continue with candidate snp
            #if one is bad, that's ok, record that and continue
            if gq1 < 20.0 and gq2 < 20.0:
                continue
            else:
                if gq1 < 20.0 and gq2 >= 20.0:
                    p1_poor_count+=1
                    genotypes[parents[0][0]] == "./.:0,0:.:0:0,0,0"
                    p1="./.:0,0:.:0:0,0,0"
                    p1_skip=True
                    p2_skip=False
                elif gq2 < 20.0 and gq1 >= 20.0:
                    p2_poor_count+=1
                    genotypes[parents[1][0]] == "./.:0,0:.:0:0,0,0"
                    p2="./.:0,0:.:0:0,0,0"
                    p2_skip=True
                    p1_skip=False
                else:
                    #both are live
                    p1_skip=False
                    p2_skip=False

                parent_alleles=[]
                if p1_skip == False:
                    if "/" in p1.split(":")[0]:
                        parent_alleles.extend(p1.split(":")[0].split("/"))
                    elif "|" in p1.split(":")[0]:
                        parent_alleles.extend(p1.split(":")[0].split("|"))
                    else:
                        raise ValueError("Parent genotype separator not recognized. SNP: " + total_record_counter)
                if p2_skip == False:
                    if "/" in p2.split(":")[0]:
                        parent_alleles.extend(p2.split(":")[0].split("/"))
                    elif "|" in p2.split(":")[0]:
                        parent_alleles.extend(p2.split(":")[0].split("|"))
                    else:
                        raise ValueError("Parent genotype separator not recognized. SNP: " + total_record_counter)


                #if both parents (or one surviving parent) are/is homozoygous for the same allele, not informative, filter
                if parent_alleles == ['1','1','1','1'] or parent_alleles == ['0','0','0','0'] or parent_alleles == ['1','1'] or parent_alleles == ['0','0']:
                    continue

                #now we filter the MGs in a loop
                #going to count samples so we can exclude the parents as we do


                missing_count=0
                for i,mg_i in enumerate(mgs_i):
                    genotype=genotypes[mg_i]
                    if genotype.split(":")[3] == ".":
                        gq=0
                    else:
                        gq=float(genotype.split(":")[3])
                    if gq < 20:
                        #if GQ is less than 20, set the genotype to missing
                        #this will catch all the genotypes that are already missing
                        genotypes[mg_i]=".:0,0:.:0:0,0,0"
                        missing_count+=1
                    else:
                        allele=genotype.split(":")[0]
                        if allele not in parent_alleles:
                            #if the genotype is not one of the parent alleles, set it to missing
                            genotypes[mg_i]=".:0,0:.:0:0,0,0"
                            missing_count+=1
                        #else keep MG genotype


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
print(f"[M]: P1 {parents[0][1]} total poor-quality genotypes: {p1_poor_count}")
print(f"[M]: P2 {parents[1][1]} total poor-quality genotypes: {p2_poor_count}")
