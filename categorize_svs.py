#!/bin/env python

import os
os.chdir('/home/FCAM/msmith/svs/minigraph_out/finalpangenome')


#functions
def handle_twollele_indel(ref_allele_length, query_allele_length, line, ef):
    global first_category, second_category
    if ref_allele_length > query_allele_length:
        first_category="DEL"
        second_category="SIMPLE"
	return True
    elif ref_allele_length < query_allele_length:
        first_category="INS"
        second_category="SIMPLE"
	return True
    else:
	ef.write(line)
	return False

def handle_twoallele_inversion(ref_allele_length, query_allele_length):
    global first_category, second_category
    first_category="INV"
    if ref_allele_length > query_allele_length:
        second_category="DEL"
    elif query_allele_length > ref_allele_length:
        second_category="INS"
    else:
        second_category="SIMPLE"

with open("sv_allele_summary.tsv") as f, open("non_inverted_equal_lengths.tsv", "a") as ef:
    with open("sv_categorized.tsv", "w") as fw:
        #skip header
        f.readline()
        for line in f:
            #define variables
            columns=line.strip().split('\t')
            prim_allele=int(0)
            prim_len=int(columns[5])
            alt_allele=int(columns[3])
            alt_len=int(columns[6])
            coast_allele=int(columns[4])
            coast_len=int(columns[7])
            inversion = bool(int(columns[8]))
            len_string=str(prim_len) + ":" + str(alt_len) + ":" + str(coast_len)

            #There's definitely a more efficient way to do this, but here we are

            #pseudo-genotype for convenience
            if alt_allele == 0 and coast_allele == 1:
                genotype="0:0:1"
            elif alt_allele == 1 and coast_allele == 0:
                genotype="0:1:0"
            elif alt_allele == 1 and coast_allele == 1:
                genotype="0:1:1"
            else:
                genotype="0:1:2"

                #Categorize variants based on variant genotype
            if genotype == "0:0:1":
                if inversion is False:
                    if not handle_twollele_indel(prim_len, coast_len, line, ef):
			continue
                elif inversion is True:
                    handle_twoallele_inversion(prim_len, coast_len)
                else:
                    raise Exception("[E]: Inversion Boolean not recognized.")
            elif genotype == "0:1:0":
                if inversion is False:
                    if not handle_twollele_indel(prim_len, alt_len, line, ef):
			continue
                elif inversion is True:
                    handle_twoallele_inversion(prim_len, alt_len)
                else:
                    raise Exception("[E]: Inversion Boolean not recognized.")
            elif genotype == "0:1:1":
                if inversion is False:
                    if not handle_twollele_indel(prim_len, alt_len, line, ef):
			continue
                elif inversion is True:
                    handle_twoallele_inversion(prim_len, alt_len)
                else:
                    raise Exception("[E]: Inversion Boolean not recognized.")
            elif genotype == "0:1:2":
                #Implicit in there being three alleles is that there is some indel activity
                longest_allele=max(prim_len, alt_len, coast_len)
                shortest_allele=min(prim_len, alt_len, coast_len)
                if inversion is False:
                    if longest_allele == prim_len:
                        first_category="DEL"
                        second_category="DEL"
                    elif shortest_allele == prim_len:
                        first_category="INS"
                        second_category="INS"
                    else: #else prim is the mid-length allele
                        first_category="INS"
                        second_category="DEL"
                elif inversion is True:
                    first_category="INV"
                    if longest_allele == prim_len:
                        second_category="DEL"
                    elif shortest_allele == prim_len:
                        second_category="INS"
                    else: #else prim is the mid-length allele
                        second_category="INDEL"
            else:
                raise Exception("[E]: Genotype not recognized.")
            newline=(columns[0],columns[1],columns[2],first_category,second_category,genotype,len_string)
            fw.write('\t'.join(map(str, newline)) + '\n')
