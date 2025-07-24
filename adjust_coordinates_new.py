#!/bin/env python

print("[M]: Beginning creation of index dictionary.")
with open("interior_primary_final.fa.fai") as f:
  previous_line = None
  length_dict={}
  for line in f:
    frag_1="primary_1"
    frag_2="primary_2"
    fields=line.strip().split('\t')
    ori_scaffold=str(fields[0])
    scaff_num=int(ori_scaffold.split('_')[1])
    
    #handle split scaffolds
    if scaff_num < 8:
      if frag_1 in ori_scaffold:
        previous_line=line #update previous line for next iteration (for fragment 2)
        length_dict.update({ori_scaffold: 0})
      else if frag_2 in ori_scaffold:
        previous_len=int(previous_line.strip().split('\t')[1])
        add=previous_len+200
        length_dict.update({ori_scaffold: add})
      else:
        raise Exception("[E]: previous line not stored correctly.")

    #handle unsplit scaffolds
    elif scaff_num > 8:
      length_dict.update({ori_scaffold: 0})

    else:
      raise Exception("[E]: scaffold number not parsed correctly.")
f.close()

#Now we have the dictionary: let's update the coordinates in sv_allele_summary.tsv
with open("sv_allele_summary.tsv", "r") as f, open("sv_allele_summary_updatedcoord.tsv", "w") as of:
  header=f.readline()
  of.write(header)
  for line in f:
    fields=line.strip().split('\t')
    



  
  
  
      
      
    
    
  
