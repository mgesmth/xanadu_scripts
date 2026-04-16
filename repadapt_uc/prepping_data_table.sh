#!/bin/bash

home=/home/FCAM/msmith
core=/core/projects/EBP/smith
linkdir=${home}/linkage_data
rawdir=${core}/linkage_snp_calling/04_raw_data
dtdir=${core}/linkage_snp_calling/02_info_files

cd ${linkdir}

#rename files to be easier to parse
ls -l *.gz > ori_filenames.txt
#all fastqs have these in their name (the same). they're not informative, i want them gone.
front_remove="NS.1712.001.NEBNext_dual_i7_"
end_remove="---NEBNext_dual_i5_"

for file in $(cat ori_filenames.txt) ; do
  new_name=$(echo "$file" | awk -v front=${front_remove} -v end=${end_remove} '{
    #get the unique identifier within the adapter section of the name (number or alphanumeric)
    #between two front sections, i.e., NS.1712.001.NEBNext_dual_i7_E2---NEBNext_dual_i5_, where E2 is the id
    #id is repeated at the end of string 2, so not losing that
    split($1,m,"-")
    split(m[1],n,"_")
    id=n[4]
    remove=front id end
    gsub(remove,"",$1)
    print
  }')
  mv "$file" "$newname"
  mv "${file}.md5" "${newname}.md5"
done

#name of each sample
##megagametophyte first
ls -1 *mg*R1.*.gz | sed 's/_R1.fastq.gz//g' > samples.txt
##now parents
ls -1 *DFI_p1*R1.*.gz | sed 's/_R1.fastq.gz//g' >> samples.txt

#ploidy
yes 1 | head -n 100 > ploidy.txt
yes 2 | head -n 2 >> ploidy.txt

#md5sums
touch md5.txt
for samp in $(cat samples.txt) ; do
  r1_md5=$(cat "${samp}_R1.fastq.gz.md5" | cut -f1 -d ' ')
  r2_md5=$(cat "${samp}_R2.fastq.gz.md5" | cut -f1 -d ' ')
  echo -e "${r1_md5}\t${r2_md5}" >> md5.txt
done

#instrument
yes "ILLUMINA" | head -n 102 > instrument.txt

#ftps, though I'm just creating a null column for shape
touch ftp.txt
for samp in $(cat samples.txt) ; do
  echo -e "NULL\tNULL" >> ftp.txt
done

#and last, r1 and r2 files
touch files.txt
for samp in $(cat samples.txt) ; do
  r1="${samp}_R1.fastq.gz"
  r2="${samp}_R2.fastq.gz"
  echo -e "${r1}\t${r2}" >> files.txt
done

#put it all together!
paste -d "\t" samples.txt ploidy.txt files.txt samples.txt instrument.txt samples.txt ftp.txt md5.txt > datatable.txt
rm ploidy.txt files.txt instrument.txt ftp.txt md5.txt samples.txt
mv datatable.txt ${dtdir}/

cd ${rawdir}
for file in $(ls -1 ${linkdir}/*.gz) ; do
  ln -s "$file" .
done
