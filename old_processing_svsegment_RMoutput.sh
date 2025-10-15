#!/bin/bash

home=/home/FCAM/msmith
dir=${home}/svs/misc
catalog=${dir}/svsegments_catalog.tsv
rm_out=segment_sequences_allout_fixed.fa.out
final_out=segment_sequences_allout_sorted.fa.out

cd ${dir}

#create sv segment catalogue
${home}/scripts/svsegments_createcatalogue.py \
${home}/svs/minigraph_out/finalpangenome/finalpangenome_filt2.bed \
${catalog}

cut -f3 ${catalog} | uniq > justseg.tmp

#remove whitespace, tab-separate RM output and remove matches that have a better match within it
./fixing_RM_out.py segment_sequences_allout.fa.out ${rm_out}

#sort RM output according to bedfile order
awk -v OFS="\t" 'NR==FNR {
  #build an associative array called order containing the correct order of the segments
  order[$1]=NR }
  NR!=FNR {
    #skip the header lines
    if ($1 ~ "SW" || $1 ~ "score") {
      next
    } else {
      #print the index number of the segment, and the line
      print order[$5],$0
    }
  }
' justseg.tmp ${rm_out} > indexed_RMout.tmp && rm justseg.tmp

#Clearly I ran repeat masked on the unfiltered SVs - some segments are not found in filt2.bed and so don't have an index number
#remove those
#commented out code is what I would have run if I didn't have this problem

head -n2 ${rm_out} | awk -v OFS='\t' '{print "index",$0}' > ${final_out}
#head -n2 ${rm_out} > ${final_out}
#sort by 7 second, this is the start position in the segment
sort -g -k1,1 -k7,7 indexed_RMout.tmp >> ${final_out} && rm indexed_RMout.tmp
#sort -k1,7g indexed_RMout.tmp | cut -f2- >> ${final_out} && rm indexed_RMout.tmp
./remove_empty_segments.py
rm ${final_out} && mv filtered.tmp ${final_out}
