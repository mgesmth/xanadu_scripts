#!/bin/env python

#get marker info, save to a tmp file (need passed marker count for first couple lines)

heterozygote={1,0}
marker_counter=0
passed_counter=0

with open("chrom_line.tmp","w") as chrom_line, open("pos_line.tmp","w") as pos_line:
    chrom_line.write("*CHROM" + " ")
    pos_line.write("*POS" + " ")

with open(vcf) as f, open(raw_tmp, "w") as of, open("chrom_line.tmp","a") as chrom_line, open("pos_line.tmp","a") as pos_line:
    for line in f:
        if line.startswith("#") == True:
            if line.startswith("#CHROM") == True:
                header=line.strip().split("\t")
                #sample names start at field 10
                info=header[0:9]
                samples=[field for field in header if field not in info]
                p1=[sample for sample in samples if "libP1" in sample][0]
                p1_i=[i for i,sample in enumerate(samples) if "libP1" in sample][0]
                p2=[sample for sample in samples if "libP2" in sample][0]
                p2_i=[i for i,sample in enumerate(samples) if "libP2" in sample][0]

            else:
                continue
        else:
            marker_counter+=1
            fields=line.strip().split('\t')
            info=fields[0:9]
            all_genos=[field for field in fields if field not in info]
            p1=all_genos[p1_i]
            p2=all_genos[p2_i]
            mg_genos=[field for i,field in enumerate(all_genos) if i not in [p1_i,p2_i]]

            #parse parental genos
            ##first check if either are missing
            #at least one should be good
            p1_gq=int(p1.split(":")[3])
            p2_gq=int(p2.split(":")[3])
            if p1_gq < 20:
                if "|" in p2.split(":")[0]:
                    p2_1=int(p2.split(":")[0].split("|")[0])
                    p2_2=int(p2.split(":")[0].split("|")[1])
                    p2_geno={p2_1,p2_2}
                elif "/" in p2.split(":")[0]:
                    p2_1=int(p2.split(":")[0].split("/")[0])
                    p2_2=int(p2.split(":")[0].split("/")[1])
                    p2_geno={p2_1,p2_2}

                if p2_geno == heterozygote:
                    marker_type="D2.16"
                else:
                    continue
                    #if one geno is missing and the other is a homozygote, site is not informative
            elif p2_gq < 20:
                if "|" in p1.split(":")[0]:
                    p1_1=int(p1.split(":")[0].split("|")[0])
                    p1_2=int(p1.split(":")[0].split("|")[1])
                    p1_geno={p1_1,p1_2}
                elif "/" in p1.split(":")[0]:
                    p1_1=int(p1.split(":")[0].split("/")[0])
                    p1_2=int(p1.split(":")[0].split("/")[1])
                    p1_geno={p1_1,p1_2}

                if p1_geno == heterozygote:
                    marker_type="D1.11"
                else:
                    continue
            elif p1_gq >= 20 and p2_gq >= 20:
                if "|" in p1.split(":")[0]:
                    p1_1=int(p1.split(":")[0].split("|")[0])
                    p1_2=int(p1.split(":")[0].split("|")[1])
                    p1_geno={p1_1,p1_2}
                elif "/" in p1.split(":")[0]:
                    p1_1=int(p1.split(":")[0].split("/")[0])
                    p1_2=int(p1.split(":")[0].split("/")[1])
                    p1_geno={p1_1,p1_2}
                if "|" in p2.split(":")[0]:
                    p2_1=int(p2.split(":")[0].split("|")[0])
                    p2_2=int(p2.split(":")[0].split("|")[1])
                    p2_geno={p2_1,p2_2}
                elif "/" in p2.split(":")[0]:
                    p2_1=int(p2.split(":")[0].split("/")[0])
                    p2_2=int(p2.split(":")[0].split("/")[1])
                    p2_geno={p2_1,p2_2}

                if p1_geno == heterozygote and p2_geno != heterozygote:
                    marker_type="D1.11"
                elif p1_geno != heterozygote and p2_geno == heterozygote:
                    marker_type="D2.16"
                elif p1_geno == heterozygote and p2_geno == heterozygote:
                    marker_type="D2.16"
                    # I trust P2 more
                    #both parents are homozygous; site is not informative
                    continue

            #now get mg genotypes
            seg_genos=[]
            for mg in mg_genos:
                mg_geno=mg.split(":")[0]
                if mg_geno == ".":
                    seg_genos.append("-")
                elif mg_geno == "0":
                    seg_genos.append("a")
                elif mg_geno == "1":
                    seg_genos.append("b")

            #ANDDDD put it all together
            passed_counter+=1
            marker_name="*" + fields[0] + "_" + fields[1]
            newline=[marker_name,marker_type] + seg_genos
            of.write(" ".join(map(str,newline)) + '\n')

            #write out chrom and pos info to tmp files
            chrom_line.write(fields[0] + " ")
            pos_line.write(fields[1] + " ")

##write necessary header
global num_mg
global mgs
with open(vcf) as f:
    for line in f:
        if line.startswith("#") == False:
            continue
        elif line.startswith("#CHROM") == True:
            header=line.strip().split("\t")
            info=header[0:9]
            samples=[field for field in header if field not in info]
            num_mg=len([sample for sample in samples if "_libP" not in sample])
            mgs=[sample for sample in samples if "_libP" not in sample]
            continue
        else:
            continue

with open(raw_tmp) as f, open(raw,"w") as of:
    num_mgs=len([sample for sample in samples if "libP" not in sample])
    #line 1 is the type of cross
    line1=['data','type','outcross']
    of.write(" ".join(map(str,line1)) + '\n')
    #line 2 contains the number of inds in the segregating pop, number of markers, if there is chrom info, if there is position info, and if there is phenotype info
    line2=[num_mg,passed_counter,1,1,0]
    of.write(" ".join(map(str,line2)) + '\n')
    #line 3 is the names of the individuals
    of.write(" ".join(map(str,mgs)) + '\n')
    for line in f:
        of.write(line.strip() + '\n')

##now add the chrom and pos lines to the end of the file

with open("chrom_line.tmp") as chrom_line, open(raw,"a") as of:
    for line in chrom_line:
        #there's only one line
        line_trimmed=line.strip()
        of.write(line_trimmed + '\n')

with open("pos_line.tmp") as pos_line, open(raw,"a") as of:
    for line in pos_line:
        #there's only one line
        line_trimmed=line.strip()
        of.write(line_trimmed + '\n')

##DONE!
