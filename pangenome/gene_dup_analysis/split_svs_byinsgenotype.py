#!/bin/env python

with open("svs_categorized_justindels.tsv") as f, open("svs_categorized_coastins.tsv","w") as coa_of, open("svs_categorized_intins.tsv","w") as int_of, open("svs_categorized_bothins.tsv","w") as both_of:
    for line in f:
        fields=line.strip().split("\t")
        allele_lens=fields[6].split(":")

        #process coastal diff lines
        if fields[5] == "0:0:1":
            if allele_lens[2] > allele_lens[0]:
                coa_of.write('\t'.join(map(str,fields)) + '\n')
            elif allele_lens[2] < allele_lens[0]:
                int_of.write('\t'.join(map(str,fields)) + '\n')
            else:
                raise Exception("[E]: comparing allele lengths for 0:0:1 record failed. check for bug!")
        elif fields[5] == "0:1:1":
            if allele_lens[1] > allele_lens[0]:
                both_of.write('\t'.join(map(str,fields)) + '\n')
            elif allele_lens[1] < allele_lens[0]:
                #in this case, the primary has the insertion, so int record
                int_of.write('\t'.join(map(str,fields)) + '\n')
            else:
                raise Exception("[E]: comparing allele lengths for 0:1:1 record failed. check for bug!")
        elif fields[5] == "0:1:0":
            if allele_lens[1] > allele_lens[0]:
                #in this case, alt haplotype has insertion, int insertion
                int_of.write('\t'.join(map(str,fields)) + '\n')
            elif allele_lens[1] < allele_lens[0]:
                #in this case, primary and coa share ins, both
                both_of.write('\t'.join(map(str,fields)) + '\n')
            else:
                raise Exception("[E]: comparing allele lengths for 0:1:0 record failed. check for bug!")
        else:
            raise Exception("[E]: Genotype not simple (i.e., 0:1:2) or some other weird error.")
