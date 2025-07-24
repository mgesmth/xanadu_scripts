#!/bin/env python

fai="/scratch/msmith/interior_primary_bigscaffoldsplit.fa.fai"
sum="/home/FCAM/msmith/svs/minigraph_out/finalpangenome/sv_allele_summary.tsv"
out="/home/FCAM/msmith/svs/minigraph_out/finalpangenome/sv_allele_summary_updatedcoord.tsv"

print("[M]: Beginning creation of index dictionary.")
with open(fai, 'r') as f:
  previous_line = None
  length_dict={}
  for line in f:
    frag_1="primary_1"
    frag_2="primary_2"
    fields=line.strip().split('\t')
    ori_scaffold=str(fields[0])
    scaff_num=int(ori_scaffold.split('_')[1])
    
    #handle split scaffolds
    if scaff_num < 7:
      if frag_1 in ori_scaffold:
        previous_line=line #update previous line for next iteration (for fragment 2)
        length_dict.update({ori_scaffold: 0})
      elif frag_2 in ori_scaffold:
        previous_len=int(previous_line.strip().split('\t')[1])
        add=previous_len+200
        length_dict.update({ori_scaffold: add})
      else:
	print(ori_scaffold)
        raise Exception("[E]: previous line not stored correctly.")

    #handle unsplit scaffolds
    elif scaff_num > 6:
      length_dict.update({ori_scaffold: 0})

    else:
      raise Exception("[E]: scaffold number not parsed correctly.")
f.close()

#Now we have the dictionary: let's update the coordinates in sv_allele_summary.tsv
with open(sum, 'r') as f, open(out, "w") as of:
  header=f.readline()
  of.write(header)
  for line in f:
    fields=line.strip().split('\t')
    scaff=str(fields[0])
    if "primary_1" in scaff:
      new_scaff=str(scaff.rsplit("_",1)[0])
      newline=(new_scaff,fields[1],fields[2],fields[3],fields[4],fields[5],fields[6],fields[7],fields[8])
    elif "primary_2" in scaff:
      new_scaff=str(scaff.rsplit("_",1)[0])
      new_start=int(fields[1])+int(length_dict[scaff])
      new_end=int(fields[2])+int(length_dict[scaff])
      newline=(new_scaff,new_start,new_end,fields[3],fields[4],fields[5],fields[6],fields[7],fields[8])
    else:
      newline=line
    of.write('\t'.join(map(str, newline)) + '\n')
      
    



  
  
  
      
      
    
    
  
