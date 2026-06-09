#!/bin/env python

import sys
import os

if __name__ == "__main__":
	vcf=sys.argv[1]
	primbedfile=sys.argv[2]
	altbedfile=sys.argv[3]
	bubblebedfile=sys.argv[4]

#functions
def paste_files(file1, file2, output_file, file3=None, delimiter='\t'):
	if file3 == None:
		with open(file1, 'r') as f1, open(file2, 'r') as f2:
			lines1 = f1.readlines()
			lines2 = f2.readlines()
			combined = [
				line1.rstrip('\n') + delimiter + line2.rstrip('\n')
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
				line1.rstrip('\n') + delimiter + line2.rstrip('\n') + delimiter + line3.rstrip('\n')
				for line1, line2, line3 in zip(lines1, lines2, lines3)
			]
			with open(output_file, 'w') as out:
				out.writelines(combined)

#this function handles the rare case where all alleles are the same length but aren't inversions (i.e., not insertion, deletion, or inversion)
def handle_twoallele_indel(ref_allele_length, query_allele_length, line, ef):
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

#will handle the case where an inversion variant is also an indel
def handle_twoallele_inversion(ref_allele_length, query_allele_length):
	global first_category, second_category
	first_category="INV"
	if ref_allele_length > query_allele_length:
		second_category="DEL"
	elif query_allele_length > ref_allele_length:
		second_category="INS"
	else:
		second_category="SIMPLE"

#parse the vcf, extract relevant info from info fields
with open(vcf, "r") as f, open("prt1.tmp", "w") as of:
	header=["scaffold","start","end","alt_allele"]
	of.write('\t'.join(header) + '\n')
	for line in f:
		if "#" in line:
			continue
		else:
			fields=line.strip().split()
			scaffold=fields[0]
			start=fields[1]
			info_fields=fields[7].split(';')
			end=info_fields[0].split('=')[1]
			alt_allele=fields[10].split(':')[0]
			newline=[scaffold,start,end,alt_allele]
			of.write('\t'.join(map(str, newline)) + '\n')

#parse the bed files to get allele specific info for each assembly (i.e., lengths)
paste_files(primbedfile, altbedfile, output_file="bed_paste.tmp")
with open("bed_paste.tmp") as f, open("prt2.tmp", "w") as of:
	header=["prim_length","alt_length"]
	of.write('\t'.join(header) + '\n')
	for line in f:
		fields=line.strip().split()
		prim_len=fields[5].split(':')[1]
		alt_len=fields[11].split(':')[1]
		newline=[prim_len,alt_len]
		of.write('\t'.join(map(str, newline)) + '\n')

# os.remove("bed_paste.tmp")

#Parse bubble bed file to get inversion info
with open(bubblebedfile) as f, open("prt3.tmp", "w") as of:
	#header
	of.write("inversion" + '\n')
	for line in f:
		fields=line.strip().split('\t')
		inversion=str(fields[5])
		of.write(inversion + '\n')

#Combine to create allele summary information, doesn't categorize the SVs
paste_files("prt1.tmp","prt2.tmp", file3="prt3.tmp", output_file="sv_allele_summary.tsv")
# os.remove("prt1.tmp")
# os.remove("prt2.tmp")
# os.remove("prt3.tmp")

counter=0
bad_counter=0
with open("sv_allele_summary.tsv") as f, open("non_inverted_equal_lengths.tsv", "a") as ef:
	with open("svs_categorized.tsv", "w") as fw:
		for line in f:
			#define variables
			columns=line.strip().split()
			if columns[0] == "scaffold" and columns[1] == "start":
				#this is the header
				fw.write("\t".join(map(str,columns)) + '\n')
				continue

			prim_allele=int(0)
			prim_len=int(columns[4])
			alt_allele=int(columns[3])
			alt_len=int(columns[5])
			inversion = bool(int(columns[6]))
			len_string=str(prim_len) + ":" + str(alt_len)
			genotype=str(prim_allele) + ":" + str(alt_allele)

			#categorize variants
			if inversion is False:
				if not handle_twoallele_indel(prim_len, alt_len, line, ef):
					continue
					bad_counter+=1
				else:
					counter+=1
			elif inversion is True:
				handle_twoallele_inversion(prim_len, coast_len)
				counter+=1
			else:
				raise ValueError("[E]: Inversion Boolean not recognized.")


			newline=(columns[0],columns[1],columns[2],first_category,second_category,genotype,len_string)
			fw.write('\t'.join(map(str, newline)) + '\n')

print(f"[M]: Done!")
print(f"[M]: Passed {counter-bad_counter} variants, failed {bad_counter}.")
