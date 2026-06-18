#!/bin/env python

mark_file="DFI_linkagemap_markers_missing0.05_segpass.txt"
#outfile="DFI_linkagemap_stringent_3mgsremoved.txt"

meg_diff_dict={}
meg_same_dict={}
meg_total_dict={}
meg_missing_dict={}
meg_evaltotal_dict={}
meg_single_mismatch_dict={}
for i in list(range(1,98)):
    meg_same_dict[i]=0
    meg_diff_dict[i]=0
    meg_total_dict[i]=0
    meg_missing_dict[i]=0
    meg_evaltotal_dict[i]=0
    meg_single_mismatch_dict[i]=0

##for checking if there is potentially a cross-over between two PHYSICALLY proximal markers
#assumes no misassemblies, but later steps will account for that

def potential_cross_over(geno,prev_geno):
    geno_check=geno==prev_geno
    #double check that marker is different truly
    if not geno_check:
        #check if the disagreements are because of missing markers
        mismatches=[(a,b) for a,b in zip(geno,prev_geno) if a != b and a != "-" and b != "-"]
        mismatches_i=[i for i,(a,b) in enumerate(zip(geno,prev_geno)) if a != b and a != "-" and b != "-"]
        if len(non_miss_mismatches) > 0:
            #there may be a real mismatch
            #final check; is it the same marker info, but in a different phase?
            #switch the genotypes of each marker (changing to c,d first as work around)
            w=["c" if g == "a" else g for g in geno]
            x=["d" if g == "b" else g for g in w]
            y=["a" if g == "d" else g for g in x]
            repul=["b" if g == "c" else g for g in y]
            second_geno_check=prev_geno==repul
            if second_geno_check:
                #marker has the same info, just in repulsion phase
                return(False)
            else:
                #check for missing mismatches again
                mismatches2=[(a,b) for a,b in zip(repul,prev_geno) if a != b and a != "-" and b != "-"]
                mismatches2_i=[i for i,(a,b) in enumerate(zip(repul,prev_geno)) if a != b and a != "-" and b != "-"]
                if len(mismatches2) > 0:
                    #this is the case where there is a genuine mismatch
                    #return whichever phase mismatch eval is smallest as that's the most likely
                    if len(mismatches) > len(mismatches2):
                        return(mismatches2_i)
                    else:
                        return(mismatches_i)
                else:
                    #marker was in repulsion phase and mismatches were because of missing genotypes
                    return(False)
    else:
        return(False)

#checks if two PHYSICALLY proximal markers have only one mg showing recomb, about adds a count to that mg's tally of single differences

def single_diff_check(geno,prev_geno,meg_single_mismatch_dict):
    geno_check=geno==prev_geno
    #double check that marker is different truly
    if not geno_check:
        #check if the disagreements are because of missing markers
        mismatches=[i for i,(a,b) in enumerate(zip(geno,prev_geno)) if a != b and a != "-" and b != "-"]
        if len(mismatches) > 0:
            #there may be a real mismatch
            #final check; is it the same marker info, but in a different phase?
            #switch the genotypes of each marker (changing to c,d first as work around)
            w=["c" if g == "a" else g for g in geno]
            x=["d" if g == "b" else g for g in w]
            y=["a" if g == "d" else g for g in x]
            repul=["b" if g == "c" else g for g in y]
            second_geno_check=prev_geno==repul
            if second_geno_check:
                #marker has the same info, just in repulsion phase
                return(False)
            else:
                #check for missing mismatches again
                mismatches2=[i for i,(a,b) in enumerate(zip(repul,prev_geno)) if a != b and a != "-" and b != "-"]
                if len(mismatches2) == 1:
                    x=int(mismatches2[0]+1)
                    meg_single_mismatch_dict[x]+=1
                    return(True)
                else:
                    #marker was in repulsion phase and mismatches were because of missing genotypes
                    return(False)
    else:
        return(False)

c=0
single_count=0
with open(mark_file) as f:
    for line in f:
        c+=1
        if c == 1:
            continue
            # skip marker
        elif c == 2:
            #first marker; pass without evaluating
            chrom=line.strip().split(" ")[0][1:].split("_")[0]
            geno=line.strip().split(" ")[2].split(",")
            prev_chrom=chrom
            prev_geno=geno
            continue 
        else:
            chrom=line.strip().split(" ")[0][1:].split("_")[0]
            geno=line.strip().split(" ")[2].split(",")

            #if chromosome is the same as last chromosome...
            if chrom == prev_chrom:
                mismatches=potential_cross_over(geno,prev_geno)
                if not mismatches:
                    prev_chrom=chrom
                    prev_geno=geno
                    continue
                    #of.write
                else:
                    #########
                    #if we've arrived here in the code, there's potentially a real recomb event
                    #this is what we're after
                    
                    if len(mismatches) == 1:
                        geno[mismatches[0]]="-"
                        print(",".join(prev_geno))
                        print(",".join(geno))
                        break
                    
                    for i in list(range(1,98)):
                        meg_total_dict[i]+=1
                        prev_allele=prev_geno[i-1]
                        allele=geno[i-1]
                        if prev_allele == "-" or allele == "-":
                            # can't evaluate; skip
                            meg_missing_dict[i]+=1
                            continue
                        else:
                            meg_evaltotal_dict[i]+=1
                            if prev_allele != allele:
                                #this is the switch
                                meg_diff_dict[i]+=1
                            else:
                                meg_same_dict[i]+=1
                    if single_diff_check(geno,prev_geno,meg_single_mismatch_dict):
                        single_count+=1
                    
            else:
                #new chromosome
                chrom=line.strip().split(" ")[0][1:].split("_")[0]
                geno=line.strip().split(" ")[2].split(",")
                prev_chrom=chrom
                prev_geno=geno
                continue
print(single_count)