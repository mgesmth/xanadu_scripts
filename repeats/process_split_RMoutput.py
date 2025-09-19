#!/usr/bin/env python

import glob
import os
import sys
import re

if __name__ == "__main__":
	in_dir=sys.argv[1]
	out_path=sys.argv[2]

prefix=out_dir.rsplit('/',1)[1]
outdir=out_dir.rsplit('/',1)[0]
sep="_"

'''
 Proccess *.out file
'''

out_files=glob.glob(os.path.join(in_dir,"interior_primary_mancur_scaffold*.fa.out"))
merged_out=sep.join((out_path, 'merged.fa.out'))

##Write header
with open(merged_out, "w") as of:
    header=('SW_score','perc_div','perc_del','perc_ins','query','query_start','query_end','query_left', 'orient','matching_repeat','repeat_family','repeat_begin','repeat_end','repeat_left','id','better_match')
    of.write('\t'.join(header) + '\n')

for file in outfiles:
    with open(file, "r") as f, open(merged_out, "a") as of:
        for line in f:
            strip=line.strip()
            #if line is empty, don't process
            if not strip:
                continue

            fields=strip.split()

            #If either of the header lines, don't process
            if fields[0] == "SW":
                continue
            elif fields[0] == "score":
                continue
            else:
                if len(fields == 16):
                    fields[15] == 'T'
                elif len(fields == 15):
                    fields[15] == 'F'
                else:
                    raise Exception('[E]: Error parsing better_match field')
                of.write('\t'.join(map(str, fields)))


'''
 Proccess *.tbl file
'''

tbl_files=glob.glob(os.path.join(in_dir,"interior_primary_mancur_scaffold*.fa.tbl"))
merged_tbl=sep.join((out_path, 'merged.fa.tbl'))

repeat_classes=['retrotransposons','SINE','Penelope','LINE','LTR','Bel/Pao','Ty1/Copia','Gypsy/DIRS1','Retroviral','DNA_transposons','rolling_circles','unclassified','sRNA','satellites','simple_repeats','low_complexity']
toplevel_classes=['genome_total','masked_total']

#create dictionary to store repeat class values
global tbl_values = {
    "total_length": 0
    "bases_masked": 0
    "retro_length": 0
    "retro_num": 0
    "sine_length": 0
    sine_num": 0
    "penelope_length": 0
    "penelope_num": 0
    "line_length": 0
    "line_num": 0
    "ltr_length": 0
    "ltr_num": 0
    "belpao_length": 0
    "belpao_num": 0
    "copia_length": 0
    "copia_num": 0
    "gypsy_length": 0
    "gypsy_num": 0
    "retroviral_length": 0
    "retroviral_num": 0
    "dna_length": 0
    "dna_num": 0
    "circle_length": 0
    "circle_num": 0
    "unclassified_length": 0
    "unclassified_num": 0
    "srna_length": 0
    "srna_num": 0
    "satellites_length": 0
    "satellites_num": 0
    "simple_length": 0
    "simple_num": 0
    "lowcomp_length": 0
    "lowcomp_num": 0
}

for file in tbl_files:
    with open(file, "r") as f:

        #set checks to starting state
        toplevel_check=1
        retro_check=0
        line_check=0
        dna_check=0
        other_check=0

        for line in f:
            #skip useless lines
            #if a separator line
            if re.match(r'=+', line) or re.match(r'-+', line'):
                continue
            #if an empty line
            elif not line.strip():
                continue
            fields=line.strip().split()


            if toplevel_check=1:
                #process turn off line first
                if fields[0] == 'Retroelements':
                    #turn off toplevel_check
                    toplevel_check=0
                    #turn on retro check to process all retro elements
                    retro_check=1
                    tbl_values["retro_length"]+=int(fields[2])
                    tbl_values["retro_num"]+=int(fields[1])
                    #this section of code will not be entered again for the rest of the file
                elif fields[0] != 'Retroelements':
                    #If top level check is on, haven't gotten to Retroelement line yet, get total length info I want
                    if fields[0] == 'total' and fields[1] == 'length:':
                        total_length+=float(fields[2])
                    elif fields[0] == 'bases' and fields[1] == 'masked:':
                        bases_masked+=float(fields[2])
                    else:
                        continue
                else:
                    raise Exception("[E]: Error while processing top level information.")

            #if past retroelement line
            elif toplevel_check=0:
                #first section (retrotransposons)
                if retro_check=1 and dna_check=0 and other_check=0:
                    #process turn off line first
                    if fields[0] == 'DNA' and fields[1] == 'transposons':
                        #dna line in output will include all sub-categories in original files
                        #I doubt it will be important to have all of them as LTRs are the biggies for conifers
                        #I can always go back and get those if I feel it's important
                        retro_check=0
                        dna_check=1
                        dna_length+=float(fields[3])
                        dna_num+=float(fields[2])
                        #this block won't be entered again
                    elif fields[0] == 'SINEs:':
                        sine_num+=float(fields[1])
                        sine_length+=float(fields[2])
                    elif fields[0] == 'Penelope:':
                        penelope_num+=float(fields[1])
                        penelope_length+=float(fields[2])

                    elif fields[0] == 'LINEs:':
                        #I'm combining all the lines categories
                        line_num+=float(fields[1])
                        line_length+=float(fields[2])
                        line_check=1
                    elif line_check=1 and fields[0] != "L1/CIN4":
                        #lines b/w LINE and last LINE subcategory
                        line_num+=float(fields[1])
                        line_length+=float(fields[2])
                    elif line_check=1 and fields[0] == "L1/CIN4":
                        #last LINE subcategory
                        line_num+=float(fields[1])
                        line_length+=float(fields[2])
                        line_check=0

                    elif fields[0] == 'LTR':
                        ltr_num+=float(fields[2])
                        ltr_length+=float(fields[4])
                    elif fields[0] == 'BEL/Pao':
                        belpao_num+=float(fields[1])
                        belpao_length+=float(fields[2])
                    elif fields[0] == 'Ty1/Copia':
                        copia_num+=float(fields[1])
                        copia_length+=float(fields[2])
                    elif fields[0] == 'Gypsy/DIRS1':
                        gypsy_num+=float(fields[1])
                        gypsy_length+=float(fields[2])
                    elif fields[0] == 'Retroviral':
                        retroviral_num+=float(fields[1])
                        retroviral_length+=float(fields[2])
                    else:
                        raise Exception("[E]: Category not recognized. Maybe Retro check wasn't turned off?")

                #process DNA transposons
            elif retro_check=0 and other_check=0 and dna_check=1:
                    #if dna_check is on, DNA transposon line has past, just waiting for rolling circles
                    if fields[0] == 'Rolling-circles':
                        dna_check=0
                        other_check=1
                        circle_num+=float(fields[1])
                        circle_length+=float(fields[2])
                    elif fields[0] == 'Other' and fields[1] == '(Mirage,':
                        #This category name has whitespace, so has to be handled differently
                        dna_num+=float(fields[2])
                        dna_length+=float(fields[3])
                    elif fields[0] == 'P-element,':
                        #the Other DNA transposon category name runs onto two lines; skipping this line as there's no data
                        continue
                    else:
                        #else it will be any other DNA transposon category
                        dna_num+=float(fields[1])
                        dna_length+=float(fields[2])

                #Process all other repeat elements
            elif retro_check=0 and dna_check=0 and other_check=1:
                #rolling circles has already been processed
                if fields[0] == 'Unclassified:':
                    unclassified_num+=float(fields[1])
                    unclassified_length+=float(fields[2])
                elif fields[0] == 'Small' and fields[1] == 'RNA:':
                    srna_num+=float(fields[2])
                    srna_length+=float(fields[3])
                elif fields[0] == 'Satellites:':
                    satellites_num+=float(fields[1])
                    satellites_length+=float(fields[2])
                elif fields[0] == 'Simple' and fields[1] == 'repeats:':
                    simple_num+=float(fields[2])
                    simple_length+=float(fields[3])
                else:
                    #else it will be low complexity
                    lowcomp_num+=float(fields[2])
                    lowcomp_length+=float(fields[3])
            else:
                raise Exception('[E]: Error processing repeat categories (past top level). Checks not recognized.')

with open(merged_tbl, "w"):
    header=['class','number_of_elements','length_of_sequence']
    of.write('\t'.join(header))
