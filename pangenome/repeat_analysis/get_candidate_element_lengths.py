#!/bin/env python

can_file="final_finalpangenome_TEs_0.85_reciprocal.out"
out_file="candidateTEs_lengths.tsv"

with open(can_file) as f, open(out_file, "w") as of:
    header=["scaffold","sv_number","TE_type","sv_seqlen","repeat_seqlen"]
    of.write("\t".join(header) + '\n')
    for line in f:
        fields=line.strip().split("\t")

        #Parse sv portion
        sv_fields=fields[4:8]
        scaffold=sv_fields[0]
        sv_num=sv_fields[1]

        #length info
        sv_alnstart=sv_fields[2].strip("()")
        if sv_alnstart > 1:
            sv_frontend_left=sv_alnstart-1
        else:
            sv_frontend_left=0
        sv_alnend=sv_fields[3].strip("()")
        sv_alnlen=sv_alnend-sv_alnstart
        sv_backend_left=sv_fields[4].strip("()")
        sv_left=sv_frontend_left+sv_backend_left
        sv_totallen=str(sv_alnlen+sv_left) #what we actually want

        #Parse repeat portion
        rep_fields=fields[10:14]
        rep_class=rep_fields[1]

        #length info
        rep_alnstart=rep_fields[2].strip("()")
        if rep_alnstart > 1:
            rep_frontend_left=rep_alnstart-1
        else:
            rep_frontend_left=0
        rep_alnend=rep_fields[3].strip("()")
        rep_alnlen=rep_alnend-rep_alnstart
        rep_backend_left=rep_fields[4].strip("()")
        rep_left=rep_frontend_left+rep_backend_left
        rep_totallen=str(rep_alnlen+rep_left) #what we actually want

        newline=[scaffold, sv_num, rep_class, sv_totallen, rep_totallen]
        of.write('\t'.join(newline) + '\n')
