#!/bin/env python

import sys
import os

if __name__ == "__main__":
	vcf=sys.argv[1]
	bedfile1=sys.argv[2]
	bedfile2=sys.argv[3]
	bedfile3=sys.argv[4]
	outfile=sys.argv[5]

def paste_files(file1, file2, file3=None, output_file, delimiter='\t'):
	if file3 is None:
    	with open(file1, 'r') as f1, open(file2, 'r') as f2:
        	lines1 = f1.readlines()
        	lines2 = f2.readlines()
			combined = [
        	line1.rstrip('\n') + delimiter + line2
        	for line1, line2 in zip(lines1, lines2)
    		]
			with open(output_file, 'w') as out:
            	out.writelines(combined)
	else:
		with open(file1, 'r') as f1, open(file2, 'r') as f2, open(file3, 'r') as f3:
        	lines1 = f1.readlines()
        	lines2 = f2.readlines()
			lines3 = f3.readlines()
			combined = [
        	line1.rstrip('\n') + delimiter + line2.rstrip('\n') + delimiter + line3
        	for line1, line2, line3 in zip(lines1, lines2, lines3)
    		]
			with open(output_file, 'w') as out:
            	out.writelines(combined)

#parse the vcf
with open(vcf, "r") as f, open("prt1.tmp", "w") as of:
	header=["scaffold","start","end","alt_allele","coast_allele"]
	of.write('\t'.join(header) + '\n')
	for line in f:
		if "##" in line:
			continue
		fields=line.strip().split('\t')
		scaffold=fields[0])
		start=fields[1]
		info_fields=fields[7].split(';')
		end=info_fields[0].split('=')[1]
		alt_allele=fields[10].split(':')[0]
		coast_allele=fields[11].split(':')[0]
		newline=[scaffold,start,end,alt_allele,coast_allele]
		of.write('\t'.join(map(str, newline)) + '\n')

#parse the bed files
paste_files(bedfile1, bedfile2, bedfile3, output_file="bed_paste.tmp")
with open("bed_paste.tmp") as f, open("prt2.tmp", "w") as of:
	header=["prim_length","alt_length","coast_length"]
	of.write('\t'.join(header) + '\n')
	for line in f:
		fields=line.strip().split('\t')
		prim_len=fields[5].split(':')[1]
		alt_len=fields[11].split(':')[1]
		coast_len=fields[17].split(':')[1]
		newline=[prim_len,alt_len,coast_len]
		of.write('\t'.join(map(str, newline)) + '\n')

#Combine
os.remove("bed_paste.tmp")
paste_files("prt1.tmp","prt2.tmp",output_file=outfile)
os.remove("prt1.tmp")
os.remove("prt2.tmp")
