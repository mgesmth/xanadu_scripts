#!/usr/bin/env python

import glob
import os
import sys
import re
import pandas as pd
import numpy as np

out_dir='/home/FCAM/msmith/repeats_mancur/concatenated_results/fa.out_files'
out_files=glob.glob(os.path.join(out_dir,"interior_primary_mancur_scaffold*.fa.out"))
tbl_dir='/home/FCAM/msmith/repeats_mancur/concatenated_results/fa.tbl_files'
tbl_files=glob.glob(os.path.join(tbl_dir,"interior_primary_mancur_scaffold*.fa.tbl"))
merged_out='/home/FCAM/msmith/repeats_mancur/concatenated_results/repeatMasker_merged.out'
merged_tbl='/home/FCAM/msmith/repeats_mancur/concatenated_results/repeatMasker_merged.tbl'


'''
 Proccess *.out file
'''

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

repeat_classes=['genome_total','masked_total','retrotransposons','SINE','Penelope','LINE','LTR','Bel/Pao','Ty1/Copia','Gypsy/DIRS1','Retroviral','DNA_transposons','rolling_circles','unclassified','sRNA','satellites','simple_repeats','low_complexity']

#create dictionary to store repeat class values
#initialize empty (with nans)
df = pd.DataFrame(columns=['number','length'], index=repeat_classes)
#change nans to 0s
tbl_values = df.fillna(0)

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
                    tbl_values['retrotransposons','number'] += int(fields[1])
                    tbl_values['retrotransposons','length'] += int(fields[2])
                    #this section of code will not be entered again for the rest of the file
                elif fields[0] != 'Retroelements':
                    #If top level check is on, haven't gotten to Retroelement line yet, get total length info I want
                    if fields[0] == 'total' and fields[1] == 'length:':
                        tbl_values['genome_total', 'length'] += int(fields[2])
                    elif fields[0] == 'bases' and fields[1] == 'masked:':
                        tbl_values['masked_total', 'length'] += int(fields[2])
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
                        tbl_values['DNA_transposons', 'number'] += int(fields[2])
                        tbl_values['DNA_transposons', 'length'] += int(fields[3])
                        #this block won't be entered again
                    elif fields[0] == 'SINEs:':
                        tbl_values['SINE', 'number'] += int(fields[1])
                        tbl_values['SINE', 'length'] += int(fields[2])
                    elif fields[0] == 'Penelope:':
                        tbl_values['Penelope', 'number'] += int(fields[1])
                        tbl_values['Penelope', 'length'] += int(fields[2])

                    elif fields[0] == 'LINEs:':
                        #I'm combining all the lines categories
                        tbl_values['LINE', 'number'] += int(fields[1])
                        tbl_values['LINE', 'length'] += int(fields[2])
                        line_check=1
                    elif line_check=1 and fields[0] != "L1/CIN4":
                        #lines b/w LINE and last LINE subcategory
                        tbl_values['LINE', 'number'] += int(fields[1])
                        tbl_values['LINE', 'length'] += int(fields[2])
                    elif line_check=1 and fields[0] == "L1/CIN4":
                        #last LINE subcategory
                        tbl_values['LINE', 'number'] += int(fields[1])
                        tbl_values['LINE', 'length'] += int(fields[2])
                        line_check=0

                    elif fields[0] == 'LTR':
                        tbl_values['LTR', 'number'] += int(fields[2])
                        tbl_values['LTR', 'length'] += int(fields[3])
                    elif fields[0] == 'BEL/Pao':
                        tbl_values['Bel/Pao', 'number'] += int(fields[1])
                        tbl_values['Bel/Pao', 'length'] += int(fields[2])
                    elif fields[0] == 'Ty1/Copia':
                        tbl_values['Ty1/Copia', 'number'] += int(fields[1])
                        tbl_values['Ty1/Copia', 'length'] += int(fields[2])
                    elif fields[0] == 'Gypsy/DIRS1':
                        tbl_values['Gypsy/DIRS1', 'number'] += int(fields[1])
                        tbl_values['Gypsy/DIRS1', 'length'] += int(fields[2])
                    elif fields[0] == 'Retroviral':
                        tbl_values['Retroviral', 'number'] += int(fields[1])
                        tbl_values['Retroviral', 'length'] += int(fields[2])
                    else:
                        raise Exception("[E]: Category not recognized. Maybe Retro check wasn't turned off?")

                #process DNA transposons
            elif retro_check=0 and other_check=0 and dna_check=1:
                    #if dna_check is on, DNA transposon line has past, just waiting for rolling circles
                    if fields[0] == 'Rolling-circles':
                        dna_check=0
                        other_check=1
                        tbl_values['rolling_circles', 'number'] += int(fields[1])
                        tbl_values['rolling_circles', 'length'] += int(fields[2])
                    elif fields[0] == 'Other' and fields[1] == '(Mirage,':
                        #This category name has whitespace, so has to be handled differently
                        tbl_values['DNA_transposons', 'number'] += int(fields[2])
                        tbl_values['DNA_transposons', 'length'] += int(fields[3])
                    elif fields[0] == 'P-element,':
                        #the Other DNA transposon category name runs onto two lines; skipping this line as there's no data
                        continue
                    else:
                        #else it will be any other DNA transposon category
                        tbl_values['DNA_transposons', 'number'] += int(fields[1])
                        tbl_values['DNA_transposons', 'length'] += int(fields[2])

                #Process all other repeat elements
            elif retro_check=0 and dna_check=0 and other_check=1:
                #rolling circles has already been processed
                if fields[0] == 'Unclassified:':
                    tbl_values['unclassified', 'number'] += int(fields[1])
                    tbl_values['unclassified', 'length'] += int(fields[2])
                elif fields[0] == 'Small' and fields[1] == 'RNA:':
                    tbl_values['sRNA', 'number'] += int(fields[2])
                    tbl_values['sRNA', 'length'] += int(fields[3])
                elif fields[0] == 'Satellites:':
                    tbl_values['satellites', 'number'] += int(fields[1])
                    tbl_values['satellites', 'length'] += int(fields[2])
                elif fields[0] == 'Simple' and fields[1] == 'repeats:':
                    tbl_values['simple_repeats', 'number'] += int(fields[2])
                    tbl_values['simple_repeats', 'length'] += int(fields[3])
                else:
                    #else it will be low complexity
                    tbl_values['low_complexity', 'number'] += int(fields[2])
                    tbl_values['low_complexity', 'length'] += int(fields[3])
            else:
                raise Exception('[E]: Error processing repeat categories (past top level). Checks not recognized.')

#write out dataframe:
tbl_values.to_csv(merged_tbl, index=True)
