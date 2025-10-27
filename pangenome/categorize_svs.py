#!/bin/env python

import sys
import os

if __name__ == "__main__":
	vcf=sys.argv[1]
	primbedfile=sys.argv[2]
	altbedfile=sys.argv[3]
	coastbedfile=sys.argv[4]
	bubblebedfile=sys.argv[5]
	outfile=sys.argv[6]

#functions
def paste_files(file1, file2, file3, output_file, delimiter='\t'):
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
	header=["scaffold","start","end","alt_allele","coast_allele"]
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
			coast_allele=fields[11].split(':')[0]
			newline=[scaffold,start,end,alt_allele,coast_allele]
			of.write('\t'.join(map(str, newline)) + '\n')

#parse the bed files to get allele specific info for each assembly
paste_files(primbedfile, altbedfile, coastbedfile, output_file="bed_paste.tmp")
with open("bed_paste.tmp") as f, open("prt2.tmp", "w") as of:
	header=["prim_length","alt_length","coast_length"]
	of.write('\t'.join(header) + '\n')
	for line in f:
		fields=line.strip().split()
		prim_len=fields[5].split(':')[1]
		alt_len=fields[11].split(':')[1]
		coast_len=fields[17].split(':')[1]
		newline=[prim_len,alt_len,coast_len]
		of.write('\t'.join(map(str, newline)) + '\n')

os.remove("bed_paste.tmp")

#Parse bubble bed file to get inversion info
with open(bubblebedfile) as f, open("prt3.tmp", "w") as of:
	#header
	of.write("inversion" + '\n')
	for line in f:
		fields=line.strip().split('\t')
		inversion=str(fields[5])
		of.write(inversion + '\n')

#Combine to create allele summary information, doesn't categorize the SVs
paste_files("prt1.tmp","prt2.tmp", "prt3.tmp", output_file="sv_allele_summary.tsv")
os.remove("prt1.tmp")
os.remove("prt2.tmp")
os.remove("prt3.tmp")

with open("sv_allele_summary.tsv") as f, open("non_inverted_equal_lengths.tsv", "a") as ef:
	with open(outfile, "w") as fw:
		#skip header
		f.readline()
		for line in f:
			#define variables
			columns=line.strip().split()
			prim_allele=int(0)
			prim_len=int(columns[5])
			alt_allele=int(columns[3])
			alt_len=int(columns[6])
			coast_allele=int(columns[4])
			coast_len=int(columns[7])
			inversion = bool(int(columns[8]))
			len_string=str(prim_len) + ":" + str(alt_len) + ":" + str(coast_len)
			#There's definitely a more efficient way to do this, but here we are - pseudo-genotype for convenience
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
					if not handle_twoallele_indel(prim_len, coast_len, line, ef):
						continue
				elif inversion is True:
					handle_twoallele_inversion(prim_len, coast_len)
				else:
					raise Exception("[E]: Inversion Boolean not recognized.")
			elif genotype == "0:1:0":
				if inversion is False:
					if not handle_twoallele_indel(prim_len, alt_len, line, ef):
						continue
				elif inversion is True:
					handle_twoallele_inversion(prim_len, alt_len)
				else:
					raise Exception("[E]: Inversion Boolean not recognized.")
			elif genotype == "0:1:1":
				if inversion is False:
					if not handle_twoallele_indel(prim_len, alt_len, line, ef):
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
