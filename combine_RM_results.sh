#!/bin/bash

for i in $(seq 1 15) ; do
  file=interior_primary_scaffold_${i}.fa.tbl
  newfile=interior_primary_scaffold_${i}_processed.tbl
  awk -F " " 'NR < 11 {
    #Handle total length figures
    if ($0 ~ /total length/) {
      total_len=$3
    } else if ($0 ~ /bases masked/) {
      total_masked_len=$3
    }
  }
  #Handle by feature type figures
  NR >= 11 {
    if ($0 ~ /Retroelements/) {
      supercat="total"
      cat="retroelement"
      num=$2
      len=$3
    } else if ($0 ~ /SINEs/) {
      supercat="retroelement"
      cat="SINE"
      num=$2
      len=$3
    } else if ($0 ~ /Penelope/) {
      supercat="retroelement"
      cat="SINE"
      num=$2
      len=$3
    } else if ($0 ~ /LINEs/) {
      supercat="retroelement"
      cat="LINE"
      num=$2
      len=$3
    } else if ($0 ~ /LTR elements/) {
      supercat="retroelement"
      cat="LTR"
      num=$2
      len=$3
    } else if ($0 ~ /DNA transposon/) {
      supercat="total"
      cat="DNA"
      num=$2
      len=$3
    } else if ($0 ~ "hobo-Activator") {
      supercat="DNA"
      cat="hobo-Activator"
      num=$2
      len=$3
    } else if ($0 ~ "Tc1-IS630-Pogo") {
      supercat="DNA"
      cat="Tc1-IS630-Pogo"
      num=$2
      len=$3
    } else if ($0 ~ "En-Spm") {
      supercat="DNA"
      cat="En-Spm"
      num=$2
      len=$3
    } else if ($0 ~ "MULE-MuDR") {
      supercat="DNA"
      cat="MULE-MuDR"
      num=$2
      len=$3
    } else if ($0 ~ "PiggyBac") {
      supercat="DNA"
      cat="PiggyBac"
      num=$2
      len=$3
    } else if ($0 ~ "Tourist/Harbinger") {
      supercat="DNA"
      cat="Tourist/Harbinger"
      num=$2
      len=$3
    } else if ($0 ~ "Other") {
      supercat="DNA"
      cat="Other"
      num=$2
      len=$3
    } else if ($0 ~ "Rolling-circles") {
      supercat="Rolling-circles"
      cat="Rolling-circles"
      num=$2
      len=$3
    } else if ($0 ~ "Rolling-circles") {
      supercat="Rolling-circles"
      cat="Rolling-circles"
      num=$2
      len=$3
    } else if ($0 ~ "Unclassified") {
      supercat="Unclassified"
      cat="Unclassified"
      num=$2
      len=$3
    } else if ($0 ~ "Total interspersed repeats") {
      supercat="Unclassified"
      cat="Unclassified"
      num="NA"
      len=$4
    } else if ($0 ~ "Small RNA") {
      supercat="Small_RNA"
      cat="Small RNA"
      num=$3
      len=$4
    } else if ($0 ~ "Satellites") {
      supercat="Satellites"
      cat="Satellites"
      num=$2
      len=$3
    } else if ($0 ~ "Simple repeats") {
      supercat="Simple-repeats"
      cat="Simple-repeats"
      num=$3
      len=$4
    } else if ($0 ~ "Low complexity") {
      supercat="Low-complexity"
      cat="Low complexity-"
      num=$3
      len=$4
    }
    print supercat,cat,num,len}' "$file" > "$newfile"
done

  
