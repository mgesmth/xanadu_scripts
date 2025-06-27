#!/bin/bash

#Formatting SV sequence RepeatMasker output
#Why is the formatting of this output so horrible????? why whitespace???????

#header
head -n2 segment_sequences.part_001.fa.out > segment_sequences_allout.fa.out
#First line of header has an indent of whitespace - can't call the actual word, so calling the three whitespaces

for file in $(cat files.txt) ; do
  awk '!/^   / && !/^score/ {print}' "$file" >> segment_sequences_allout.fa.out
done

#making it as a CSV because I think that will be more straightforward for removing the whitespace
echo -e "SW_score,perc_div,perc_ins,query_seq,query_begin,query_end,query_left,repeat,repeat_begin,repeat_end,repeat_left,ID,better_match" > new.out
#leave header as-is; sub one or more occurrences of blanks with commas; the front of the line may start with whitespace (now comma); if so, trim it off, if not, print as is
awk '/^SW/ {print} !/^SW/ {
  gsub(/[[:blank:]]+/, ",")
  if ($1 ~ /^,/) {
    print substr($0,2)
  } else {
    print
  }
}' new.out > new2.out
