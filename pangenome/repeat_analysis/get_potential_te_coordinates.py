#!/bin/env python

import os

te="repeat_masker_dir/byscaffold_svs_0.85/insertions_potentialTE.tsv"
bed="lastpangenome_filtered2_unbroken.bed"

def write_tmp_chr(chrom,line,of):
	fields=line.strip().split("\t")
	if fields[0] == chrom:
		of.write("\t".join(fields) + '\n')

for i in range(1,14):
	chrom="chr" + str(i)
	tetmp=chrom + "_te.tmp"
	bedtmp=chrom + "_bed.tmp"
	with open(te) as f1, open(tetmp,"w") as of1:
		for line in f1:
			write_tmp_chr(chrom,line,of1)
	with open(bed) as f2, open(bedtmp,"w") as of2:
		for line in f2:
			write_tmp_chr(chrom,line,of2)
	
for i in range(1,14):
	chrom="chr" + str(i)
	tetmp=chrom + "_te.tmp"
	bedtmp=chrom + "_bed.tmp"
	with open(tetmp) as f, open("insertions_potentialTE_genomiccoord.tsv","a") as of:
		for line1 in f:
			fields1=line1.strip().split("\t")
			sv=int(fields1[1][2:])
			j=0
			with open(bedtmp) as bed:
				for line2 in bed:
					j+=1
					if j == sv:
						fields2=line2.strip().split("\t")
						newline=[chrom,fields2[1],fields2[2],fields1[4]]
						of.write("\t".join(map(str,newline)) + '\n')
						break
					else:
						continue

	os.remove(tetmp)
	os.remove(bedtmp)
