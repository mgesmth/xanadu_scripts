#!/bin/bash

awk 'BEGIN { OFS = "\t" } !/^#/ {

  contig=$1
  start=$2
  split($8, m, ";", sepsm)
  split(m[1], n, "=", sepsn)
  end=n[2]

  print contig,start,end,$8,$10,$11,$12
  
}' all_dougfir_scaffcoord.sv.vcf > all_dougfir_scaffcoord.sv.bed 
