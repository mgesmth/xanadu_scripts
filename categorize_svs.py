#!/bin/env python

import os
os.chdir(~/svs/minigraph/finalpangenome)

#functions
def handle_twollele_indel(ref_allele_length, query_allele_length):
    if ref_allele_length > query_allele_length:
        first_category="DEL"
        second_category="SIMPLE"
    elif ref_allele_length < query_allele_length:
        first_category="INS"
        second_category="SIMPLE"
    else:
        raise Exception("[E]: Non-inverted variant has equal allele lengths.")

def handle_twoallele_inversion(ref_allele_length, query_allele_length):
    first_category="INV"
    if ref_allele_length > query_allele_length:
        second_category="DEL"
    elif query_allele_length > ref_allele_length:
        second_category="INS"
    else:
        second_category="SIMPLE"

with open("sv_allele_summary.tsv") as f:
    with open("sv_categorized.tsv", "w") as fw:
        #return this first line as is - header line
        f.readline()
        for line in f:
            #define variables
            columns=line.strip()split('\t')
            prim_allele=int(0)
            prim_len=float(columns[6])
            alt_allele=int(columns[4])
            alt_len=float(columns[7])
            coast_geno=int(columns[5])
            coast_allele=float(columns[8])
            inversion=bool(columns[9])

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
                    handle_twollele_indel(prim_len, coast_len)
                elif inversion is True:
                    handle_twoallele_inversion(prim_len, coast_len)
                else:
                    raise Exception("[E]: Inversion Boolean not recognized.")
            elif genotype == "0:1:0":
                if inversion is False:
                    handle_twollele_indel(prim_len, alt_len)
                elif inversion is True:
                    handle_twoallele_inversion(prim_len, alt_len)
                else:
                    raise Exception("[E]: Inversion Boolean not recognized.")
            elif genotype == "0:1:1":
                if inversion is False:
                    handle_twollele_indel(prim_len, alt_len)
                elif inversion is True:
                    handle_twoallele_inversion(prim_len, alt_len)
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

            print()
