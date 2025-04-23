#!/bin/bash

awk 'BEGIN { OFS = "\t" } /^#/ {next} {print $6,$2,$3,0,$7,$4,$5,1}' test_juicertools.pairs | \
	sed 's/+/0/g' | sed 's/-/1/g' > test_juicertools_shortform.pairs 

#awk 'BEGIN { OFS = "\t" } 
#	!/^#/ {print $6,$2,$3; sub(/+/, "0"); print sub(/-/, "1");} 
#	{print $6,$2,$3,0,$7,$4,$5,1}' test_juicertools.pairs > test_juicertools_shortform.pairs

#awk 'BEGIN { OFS="\t" } /^#/ { next } {
#    gsub(/\+/, "0", $6);
#    gsub(/-/, "1", $6);
#    gsub(/\+/, "0", $7);
#    gsub(/-/, "1", $7); 
#    print $6,$2,$3,0,$7,$4,$5,1
#}' test_juicertools.pairs | cat
 
#> test_juicertools_shortform.pairs

