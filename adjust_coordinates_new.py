#!/bin/env python

import pandas as pd

fai=open('interior_primary_final.fa.fai')
ori_index=fai.readlines()

length_dict={}
#handle broken scaffolds
for i in 0:13:
  columns=ori_index[i].strip().split('\t')
  name=columns[0]
  frag_num=columns[0].split('_')[3]
  if frag_num = 1:
    length_dict.update({name: 0})
    #First fragment comes first; create the add number when processing that fragment, 
    #apply it when processing the second fragment
    add=columns[1]+200 #add 200 for the gap
  else if frag_num = 2:
    length_dict.update({name: add})

#handle unbroken scaffolds
for i in 14:3011
  columns=ori_index[i].strip().split('\t')
  name=columns[0]
  length_dict.update({name: 0})

  
  
  
      
      
    
    
  
