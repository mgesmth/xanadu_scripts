#!/bin/env python

file="DFI_linkagemap_markers_1kb_segpass_notbinned.txt"
prev_chrom="dummy"

def potential_cross_over(geno,prev_geno):
    geno_check=geno==prev_geno
    #double check that marker is different truly
    if not geno_check:
        #check if the disagreements are because of missing markers
        mismatches=[(a,b) for a,b in zip(geno,prev_geno) if a != b]
        #find ordered mismatches between markers that aren't because of a missing genotype
        non_miss_mismatches=[mis for mis in mismatches if "-" not in mis]
        if len(non_miss_mismatches) > 0:
            #there may be a real mismatch
            #final check; is it the same marker info, but in a different phase?
            #switch the genotypes of each marker (changing to c,d first as work around)
            w=["c" if g == "a" else g for g in geno]
            x=["d" if g == "b" else g for g in w]
            y=["a" if g == "d" else g for g in x]
            repul=["b" if g == "c" else g for g in y]
            second_geno_check=prev_geno==repul
            if second_geno_check:
                #marker has the same info, just in repulsion phase
                return(False)
            else:
                #check for missing mismatches again
                mismatches=[(a,b) for a,b in zip(repul,prev_geno) if a != b]
                non_miss_mismatches=[mis for mis in mismatches if "-" not in mis]
                if len(non_miss_mismatches) > 0:
                    #this is the case where there is a genuine mismatch
                    return(True)
                else:
                    #marker was in repulsion phase and mismatches were because of missing genotypes
                    return(False)
    else:
        return(False)


c=0
weird_marker=0
with open(file) as f:
	for line in f:
		c+1
		if c == 1:
			continue

		chrom=line.strip().split(" ")[0][1:].split("_")[0]
		pos=int(line.strip().split(" ")[0][1:].split("_")[1])
		geno=line.strip().split(" ")[2].split(",")

		if chrom != prev_chrom:
			d=1
			left_chrom=chrom
			left_pos=pos
			left_geno=geno
			left_line=line.strip()

		else:
			d+=1
			if d == 2:
				eval_chrom=chrom
				eval_pos=pos
				eval_geno=geno
				eval_line=line.strip()
			else:
				right_chrom=chrom
				right_pos=pos 
				right_geno=geno
				right_line=line.strip()

			#step 1: eval left and right markers

			right_left_check=potential_cross_over(right_geno,left_geno)
			if right_left_check:
				#theres a potential cross over, so the evaluation isn't valid. Shift the window.
				left_chrom=eval_chrom
				left_pos=eval_pos
				left_geno=eval_geno
				left_life=eval_line 

				eval_chrom=right_chrom
				eval_pos=right_pos
				eval_geno=right_geno
				eval_line=right_line
			else:
				#no cross over between right and left.
				left_eval_check=potential_cross_over(left_geno,eval_geno)
				if not left_eval_check:
					#there's not reported recomb event, meaning all three markers have the same info.
					#just write the first one (left)
					#of.write(left_line + '\n')
					#keep left marker as left marker for next evaluation, but send the next line to d == 2 as we need to accumulate a new eval and right line
					d=1
				else:
					#there's a reported recomb event between two markers that have the same info
					weird_marker+=1


print(weird_marker)

