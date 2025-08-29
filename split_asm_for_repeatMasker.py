#!/bin/env python

import sys
import os
from Bio import SeqIO

if __name__ == "__main__":
	asm_fasta=sys.argv[1]
	asm_faidx=sys.argv[2]
	outdir=sys.argv[3]
	tmpdir=sys.argv[4]

asm_basename=os.path.basename(asm)

#name tmp fastas
tmpfa_1=tmpdir + "20_tmp.fa"
tmpfa_2=tmpdir + "above1Mb_tmp.fa"
tmpfa_3=tmpdir + "below1Mb_tmp.fa"

#name out
outdir_1=outdir + "repeatMasker_20"
outdir_2=outdir + "repeatMasker_above1Mb"
outdir_3=outdir + "repeatMasker_below1Mb"

def split_fasta(in_fa, outdir="split_fa", prefix=asm_basename):
    os.makedirs(outdir, exist_ok=True)
    for i, record in enumerate(SeqIO.parse(input_fasta, "fasta"), start=1):
        out_file = os.path.join(outdir, f"{prefix}{i}.fa")
        SeqIO.write(record, out_file, "fasta")

with open(asm_faidx, "r") as in_fai:
	for line in in_fai:
		fields=line.strip().split('\t')
		if fields[1] >= 1000000:
			prevline_fields=fields
		elif fields[1] < 1000000 && prevline_fields[1] >=1000000:
			global last_above1MB_scaffnum=prevline_fields[0].split('_')[1]
			global first_below1MB_scaffnum=fields[0].split('_')[1]

with open(asm_fasta, "r") as in_fa, open(tmpfa_1, "w") as twenty_fa, open(tmpfa_2, "w") as above_fa, open(tmpfa_3, "w") as below_fa:
	for line in in_fa:
		line=line.strip()
		if ">" in line:
			scaffnum=line.split("_")[1]
			'''
			this loop is only entered if it's a header line, so the scaffnum variable stays set while the sequence belonging to the header is being parsed
			'''
		if scaffnum <= 20:
			twenty_fa.write(line + '\n')
		elif scaffnum > 20 && scaffnum <= last_above1MB_scaffnum:
			above_fa.write(line + '\n')
		elif scaffnum > 20 && scaffnum >= first_below1MB_scaffnum:
			below_fa.write(line + '\n')
		else:
			raise Exception("[E]: Parsing of original fasta file failed. Exiting.")

if not split_fasta(tmpfa_1, outdir=outdir_1, prefix="scaffold_"):
	raise Exception("[E]: Splitting of first 20 fasta file failed. Exiting.")

if not split_fasta(tmpfa_2, outdir=outdir_2, prefix="scaffold_"):
	raise Exception("[E]: Splitting of above 1Mb fasta file failed. Exiting.")
else:
	



		#process header
		if ">" in line:
