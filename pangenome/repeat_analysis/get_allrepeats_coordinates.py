#!/bin/env python

rep="repeat_masker_dir/byscaffold_svs_0.85/all_svs.fasta.out"
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
		if len(fields) == 16:
			continue

		#check if element is intact LTR
		if ("LTR" in fields[10]):
			start=int(fields[11].strip("()"))
			end=int(fields[12].strip("()"))
			back_left=int(fields[13].strip("()"))
			if start == 0:
				front_left=0
			else:
				front_left=start-1
			total_left=front_left+back_left
			align_length=end-start
			total_length=total_left+align_length
			prop_covered=align_length/total_length
			if (prop_covered == 1):
				fields[10]=fields[10] + "_intact"

		id=fields[4]
		coords=idx[id].split(",")
		newline=[fields[4].split("_")[0],coords[0],coords[1],fields[10]]
		of.write("\t".join(map(str,newline)) + '\n')
		continue






























		









