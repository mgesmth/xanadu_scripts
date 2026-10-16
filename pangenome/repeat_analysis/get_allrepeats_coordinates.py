#!/bin/env python

rep="repeat_masker_dir/byscaffold_svs_0.85/all_svs.fasta.out.parsed"
bed="lastpangenome_filtered2_unbroken.bed"

idx={}
prevchrom="dummy"
with open(bed) as f:
	for line in f:
		fields=line.strip().split()
		chrom=fields[0]
		if chrom != prevchrom:
			j=1
		else:
			j+=1

		id=chrom + "_sv" + str(j)
		coord=fields[1] + "," + fields[2]
		idx[id]=coord
		prevchrom=chrom
		continue

with open(rep) as f, open("insertions_all_genomiccoord_new.tsv","w") as of:
	for line in f:
		fields=line.strip().split()
		id=fields[0] + "_" + fields[1]
		coords=idx[id].split(",")
		newline=[fields[0],fields[1],coords[0],coords[1],fields[4]]
		of.write("\t".join(map(str,newline)) + '\n')
		continue






























		









