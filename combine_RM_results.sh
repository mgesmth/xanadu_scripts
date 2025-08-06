#!/bin/bash

for i in $(seq 1 15) ; do
  file=interior_primary_scaffold_${i}.fa.tbl
  newfile=interior_primary_scaffold_${i}_processed.tbl
  awk -F " " 'BEGIN { OFS = "\t" } NR < 11 {
    #Handle total length figures
    if ($0 ~ /total length/) {
      total_len=$3
    } else if ($0 ~ /bases masked/) {
      total_masked_len=$3
    }
  }
  #Handle by feature type figures
  NR >= 11 {
    if ($1 ~ /Retroelements/) {
      supercat="total"
      cate="retroelement"
      num=$2
      len=$3
    } else if ($1 ~ /SINEs/) {
      supercat="retroelement"
      cate="SINE"
      num=$2
      len=$3
    } else if ($1 ~ /Penelope/) {
      supercat="retroelement"
      cate="SINE"
      num=$2
      len=$3
    } else if ($1 ~ /LINEs/) {
      supercat="retroelement"
      cate="LINE"
      num=$2
      len=$3
    } else if ($1 ~ /LTR elements/) {
      supercat="retroelement"
      cate="LTR"
      num=$3
      len=$4
    } else if ($1 ~ /DNA transposon/) {
      supercat="total"
      cate="DNA"
      num=$3
      len=$4
    } else if ($1 ~ "hobo-Activator") {
      supercat="DNA"
      cate="hobo-Activator"
      num=$2
      len=$3
    } else if ($1 ~ "Tc1-IS630-Pogo") {
      supercat="DNA"
      cate="Tc1-IS630-Pogo"
      num=$2
      len=$3
    } else if ($1 ~ "En-Spm") {
      supercat="DNA"
      cate="En-Spm"
      num=$2
      len=$3
    } else if ($1 ~ "MULE-MuDR") {
      supercat="DNA"
      cate="MULE-MuDR"
      num=$2
      len=$3
    } else if ($1 ~ "PiggyBac") {
      supercat="DNA"
      cate="PiggyBac"
      num=$2
      len=$3
    } else if ($1 ~ "Tourist/Harbinger") {
      supercat="DNA"
      cate="Tourist/Harbinger"
      num=$2
      len=$3
    } else if ($1 ~ "Other") {
      supercat="DNA"
      cate="Other"
      num=$4
      len=$5
    } else if ($1 ~ "Rolling-circles") {
      supercat="Rolling-circles"
      cate="Rolling-circles"
      num=$2
      len=$3
    } else if ($1 ~ "Rolling-circles") {
      supercat="Rolling-circles"
      cate="Rolling-circles"
      num=$2
      len=$3
    } else if ($1 ~ "Unclassified") {
      supercat="Unclassified"
      cate="Unclassified"
      num=$2
      len=$3
    } else if ($1 ~ "Total interspersed repeats") {
      supercat="Unclassified"
      cate="Unclassified"
      num="NA"
      len=$4
    } else if ($1 ~ "Small RNA") {
      supercat="Small-RNA"
      cate="Small-RNA"
      num=$3
      len=$4
    } else if ($1 ~ "Satellites") {
      supercat="Satellites"
      cate="Satellites"
      num=$2
      len=$3
    } else if ($1 ~ "Simple repeats") {
      supercat="Simple-repeats"
      cate="Simple-repeats"
      num=$3
      len=$4
    } else if ($1 ~ "Low complexity") {
      supercat="Low-complexity"
      cate="Low-complexity"
      num=$3
      len=$4
    }
    print supercat,cate,num,len}' "$file" > "$newfile"
done
