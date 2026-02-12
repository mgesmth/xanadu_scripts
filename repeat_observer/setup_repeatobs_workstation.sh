#!/bin/bash

#adapted from Marie's DouglasFirNotes/repeats_notes_scripts/repeat_observer_workstation_setup.sh,
#which was adapted from RepeatObservers's Setup_Run_Repeats.sh 

core=/core/projects/EBP/smith
sp_name="intDF_H0"
#testing on scaffold 10 of V2
genome=${core}/projects/EBP/smith/manual_curation_files/interior_primary_final_mancur2_10.fa

module load seqkit/2.10.0

cd $core
mkdir repeat_observer
cd repeat_observer
mkdir input_chrs
mkdir input_chrs/${sp_name}
mkdir input_chrs/${sp_name}/chromosome_files
mkdir output_chrs
mkdir output_chrs/${sp_name}

cd input_chrs/${sp_name}/chromosome_files
seqkit seq -w 60 ${genome} > ${spp_h}_2.fasta
#split chromosomes into files
awk '/^>/ { file=substr($1,2) ".fasta" } { print > file }' ${spp_h}_2.fasta
#delete all chrs smaller than 8Mb
find -type f -size -8000000c -delete
#remove the tmp file
rm ${spp_h}_2.fasta
i=1
for old_name in $(ls -1 *.fasta); do
  new_name=${sp_name}_chr${i}.fasta
  mv "$old_name" "$new_name"
  echo "changed $old_name to ${new_name}" >> ../chrom_rename.txt
  i=$((i+1))
done

# loop to split long chromosomes into parts that are each 100Mbp long
ls -1 *.fasta > ../list_chromosomes.txt
sed 's/.fasta//g' ../list_chromosomes.txt > ../list_chrnum.txt
while IFS= read -r Chr; do
  split -l 1666666 ${Chr}.fasta ${Chr}part --numeric-suffixes=1
  rm ${Chr}.fasta
done < ../list_chrnum.txt

cd ..
find ./chromosome_files/ -type f -exec mv {} {}".fasta" \;
