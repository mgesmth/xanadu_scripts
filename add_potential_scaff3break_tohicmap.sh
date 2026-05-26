#!/bin/bash

wd=/core/projects/EBP/smith/3ddna_again
cd $wd
#fragments included in the existing scaffold 3:
frag_array=(1 3 5 7 9 13 15 19 21 23 25)

final_supertrack=interior_primary_final.final_asm.superscaf_track.txt
final_scafftrack=interior_primary_final.final_asm.scaffold_track.txt
final_asm=interior_primary_final.final.assembly
FINAL_asm=interior_primary_final.FINAL.assembly

#get fragment lengths
touch scaffold_3_primary_fragmentlengths.txt
for i in $(seq 0 10) ; do
  fragment=${frag_array[$i]}
  grep -w "scaffold_3_primary:::fragment_${fragment}" ${FINAL_asm}| grep -v "gap" | cut -d " " -f1,3 >> scaffold_3_primary_fragmentlengths.txt
done

#build coordinates for the fragments that correspond to their coordinates in the finished assembly (12-chr assembly), with 200N gaps padding between each fragment. This will allow us to translate the potential breakpoint coordinates to those of the contact map.

awk ' NR==1 {
  start=1
  end=$2
  print substr($1,2),start,end
  rolling_add=end+199
  next
} {
  start=1+rolling_add
  end=start+$2
  if ()
  print substr($1,2),start,end
  rolling_add=end+199
}' scaffold_3_primary_fragmentlengths.txt > scaffold_3_primary_frags_contextualized.txt

#the potential break is from somewhere in fragment 5 to somewhere in fragment 9 (or anywhere in fragment 7, potentially at one of the breakpoints)

candidates=("scaffold_3_primary:::fragment_5" "scaffold_3_primary:::fragment_7" "scaffold_3_primary:::fragment_9")

for i in $(seq 0 2) ; do
  cand=${candidates[$i]}
  awk -v OFS="\t" -v cand="$cand" 'NR==1 {
    next
  }{
    if (substr($8,2) == cand) {
      print substr($8,2),$10,$11
    }
  }' ${final_scafftrack}
done

#translate coordinates
##from scaffold_3_primary_frags_contextualized.txt and potential_scaffold3_break.bed
pot_break_start=605667941
pot_break_end=622612770
frag_5_start=450561069
frag_5_end=612561069
frag_9_start=622561469
frag_9_end=655561469

frag_5_add=$(echo $((${pot_break_start}-${frag_5_start})))
frag_9_add=$(echo $((${pot_break_end}-${frag_9_start})))

#from ${final_scafftrack} - the start coordinate of 3_fragment_5 and 3_fragment_9 (field 10)
in_asm_frag_5_start=3524598057
in_asm_frag_9_start=3696598057
modified_start=$(echo $((${in_asm_frag_5_start}+${frag_5_add})))
modified_end=$(echo $((${in_asm_frag_9_start}+${frag_9_add})))
