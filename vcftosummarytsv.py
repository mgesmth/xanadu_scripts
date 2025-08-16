#!/bin/env python

import sys

if __name__ == "__main__":
	vcf=sys.argv[1]
	outfile=sys.argv[2]
	errfile=sys.argv[3]

#parse the vcf
with open(vcf, "r") as f, open(outfile, "w") as of:
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
