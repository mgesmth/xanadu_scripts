#!/bin/env python

import sys
import re

if __name__ == "__main__":
    file_type=sys.argv[1] #one of "bed", "gff", "vcf"
    input_file=sys.argv[2]
    output_file=sys.argv[3]

#for 1:1 chr translations (i.e., not scaffold_3_primary)
map_dict_1to1={"scaffold_1_primary" : "chr1",
"scaffold_2_primary" : "chr2",
"scaffold_4_primary" : "chr3",
"scaffold_5_primary" : "chr4",
"scaffold_6_primary" : "chr5",
"scaffold_7_primary" : "chr6",
"scaffold_8_primary" : "chr7",
"scaffold_9_primary" : "chr8",
"scaffold_10_primary" : "chr9",
"scaffold_11_primary" : "chr10",
"scaffold_12_primary" : "chr11",
}

counter=0
error_counter=0
if file_type=="bed":

    #bed is half 0-based i.e., [x,y)
    chr13=[0,622561269]
    chr12=[622561269+200,1437716149]
    chr13_len=622561269
    chr12_len=815154680

    with open(input_file) as f, open(output_file, "w") as of:
        for line in f:
            if line.startswith("#") == True:
                #if a header line
                #not necessarily going to be a header line
                of.write(line.strip() + '\n')
                continue
            else:
                counter+=1
                fields=line.strip().split("\t")
                scaffold=fields[0]
                if scaffold == "scaffold_3_primary":
                    #if it's scaffold_3, which is becoming chr 12 and chr 13
                    start=int(fields[1])
                    end=int(fields[2])

                    if end <= chr13[1]: #chr 13 records
                        fields[0]="chr13"
                        of.write("\t".join(map(str,fields)) + "\n")
                    elif start <= chr13[1] and end > chr13[1]:
                        #if a record spans the break, ditch it
                        print(f"[M]: Record on line {counter} spans the chr12/chr13 break. Omitting from output.")
                        error_counter+=1
                        continue
                    elif start >= chr13[1] and start <= chr12[0]:
                        #if a record falls in the break, ditch it
                        print(f"[M]: Record on line {counter} falls within the chr12/chr13 break. Omitting from output.")
                        error_counter+=1
                        continue
                    elif end >= chr13[1] and end <= chr12[0]:
                        #if a record falls in the break, ditch it
                        print(f"[M]: Record on line {counter} falls within the chr12/chr13 break. Omitting from output.")
                        error_counter+=1
                        continue
                    elif start >= chr12[0]: #chr 12 records
                        fields[0]="chr12"
                        fields[1]=start-chr12[0]+1
                        fields[2]=end-chr12[0]
                        of.write("\t".join(map(str,fields)) + "\n")
                else:
                    num=int(scaffold.split("_")[1])
                    if num > 12: # a minor scaffold
                        new_scaffnum=num+1
                        fields[0]="_".join(map(str,["scaffold",new_scaffnum]) + '\n')
                        of.write("\t".join(map(str,fields)) + "\n")
                    else: # major scaffolds not 3
                        fields[0]=map_dict_1to1[scaffold]
                        of.write("\t".join(map(str,fields)) + "\n")

###

elif file_type=="vcf":

    #vcf is 1-based
    chr13=[1,622561269]
    chr12=[622561270+200,1437716149]
    chr13_len=622561269
    chr12_len=815154680

    with open(input_file) as f, open(output_file,"w") as of:
        for line in f:
            if line.startswith("#") == True: # handle header

                if line.startswith("##contig=") == True: #if the header has the contig length info, change it to match new names and lengths
                    #isolate original scaffold
                    ori_scaffold=line.strip().split(",")[0].rsplit("=",1)[1]
                    #if it's in the chr list (i.e., not scaffold_3 or a minor scaffold), modify name
                    if ori_scaffold in list(map_dict_1to1.keys()):
                        new_line=line.strip().replace(ori_scaffold,map_dict_1to1[ori_scaffold])
                        of.write(new_line + '\n')
                        if ori_scaffold == "scaffold_12_primary":
                            #write chr12 and chr13 records after the chr11 record, as they don't exist in the original vcf
                            of.write("".join(map(str,["##contig=<ID=","chr12,","length=",chr12_len,">"])) + "\n")
                            of.write("".join(map(str,["##contig=<ID=","chr13,","length=",chr13_len,">"])) + "\n")
                    elif ori_scaffold == "scaffold_3_primary":
                        continue
                    else:
                        #if a minor scaffold
                        #name minor scaffolds need to be increased by one (since there's one more chr)
                        new_scaffnum=int(ori_scaffold.split("_")[1])+1
                        new_scaffold="_".join(map(str,["scaffold",new_scaffnum]))
                        new_line=re.sub(ori_scaffold,new_scaffold,line.strip())
                        of.write('\t'.join(map(str,new_line)) + '\n')
                else: # else a header line, but not a contig line
                    of.write(line.strip() + '\n')

            else: #h andle records
                counter+=1
                fields=line.strip().split("\t")
                ori_scaffold=fields[0]

                if ori_scaffold in list(map_dict_1to1.keys()): # if a major scaffold, not 3 (now 12 and 13)
                    fields[0]=map_dict_1to1[ori_scaffold]
                    of.write("\t".join(map(str,fields)) + '\n')
                elif ori_scaffold == "scaffold_3_primary": # if scaffold 3 (now 12 and 13)
                    pos=fields[1]
                    if pos <= chr13[1]:
                        #if pos is less than the end of chr13, the SNP is on 13 and the pos doesn't need to be changed
                        fields[0]="chr13"
                        of.write("\t".join(map(str,fields)) + '\n')
                    elif pos >= chr12[0]:
                        #if pos is greater the start of chr12, SNP is on 12 and pos needs to be changed
                        fields[0]="chr12"
                        fields[1]=pos-chr13_len+200 # +200 for the gap that was between the two contigs connecting 12/13
                        of.write("\t".join(map(str,fields)) + '\n')
                    else:
                        raise ValueError(f"[E]: Record {counter} appears to be between chrs 12 and 13. Check it out.")
                else:
                    #is a minor scaffold
                    new_scaffnum=int(ori_scaffold.split("_")[1]+1)
                    fields[0]="_".join(map(str,["scaffold",new_scaffnum]))
                    of.write("\t".join(map(str,fields)) + '\n')


###

elif file_type=="gff":

    #gff genome annotation was done when the scaffolds were still named HiC_scaffold_x, so the dictionary is different
    map_dict_1to1={"HiC_scaffold_1" : "chr1",
    "HiC_scaffold_2" : "chr2",
    "HiC_scaffold_4" : "chr3",
    "HiC_scaffold_5" : "chr4",
    "HiC_scaffold_6" : "chr5",
    "HiC_scaffold_7" : "chr6",
    "HiC_scaffold_8" : "chr7",
    "HiC_scaffold_9" : "chr8",
    "HiC_scaffold_10" : "chr9",
    "HiC_scaffold_11" : "chr10",
    "HiC_scaffold_12" : "chr11",
    }

    #gff is 1-based
    chr13=[1,622561269]
    chr12=[622561270+200,1437716149]
    chr13_len=622561269
    chr12_len=815154680

    with open(input_file) as f, open(output_file, "w") as of:
        for line in f:
            if line.startswith("#") == True: # handle header
                if line.startswith("##sequence-region") == True:
                    #these are index lines, but I don't want to try to fix them.
                    #skip
                    continue
                else:
                    of.write(line.strip() + '\n')
                    continue
            else:
                counter+=1
                fields=line.strip().split("\t")
                ori_scaffold=fields[0]

                if ori_scaffold in list(map_dict_1to1.keys()): #major scaffold not 3 (now 12 and 13)
                    fields[0]=map_dict_1to1[ori_scaffold]
                    of.write("\t".join(map(str,fields)) + '\n')
                elif ori_scaffold == "HiC_scaffold_3": #scaffold 3 (now 12 and 13)
                    start=int(fields[3])
                    end=int(fields[4])
                    if start >= chr13[0] and end <= chr13[1]: #handle chr13 records
                        fields[0]="chr13"
                        of.write("\t".join(map(str,fields)) + '\n')
                        continue
                    elif start >= chr12[0]: #handle chr12 records
                        #change the chr name and start/end coordinates
                        fields[0]="chr12"
                        fields[3]=start-chr13_len+200
                        fields[4]=start-chr13_len+200
                        of.write("\t".join(map(str,fields)) + '\n')
                        continue
                    else:
                        raise ValueError(f"[E]: Coordinate at record {counter} appears to span break between chrs 12 and 13. Check it out.")
                else: #else minor scaffolds
                    new_scaffnum=int(ori_scaffold.split("_")[2])+1
                    fields[0]="_".join(map(str,["scaffold",new_scaffnum]))
                    of.write("\t".join(map(str,fields)) + '\n')
                    continue

else:
    raise ValueError(f"[E]: File type {file_type} not recognized.")

print(f"[M]: Done! Parsed {file_type}, passing {error_counter} errors.")
