#!/bin/bash

top=/home/mg615512
home=${top}/projects/def-booker/mg615512
rawdir=${home}/snp_calling/04_raw_data
dtdir=${home}/snp_calling/02_info_files
#where raw data is being stored
linkdir=${top}/scratch/mg615512/linkage_data

cd ${linkdir}

#name of each sample
##megagametophyte first
ls -1 *mg*R1.*.gz | sed 's/_R1.fastq.gz//g' > samples.txt
##now parents
ls -1 *DFI_p1*R1.*.gz | sed 's/_R1.fastq.gz//g' >> samples.txt

#defining sra based on library id
awk 'NR <= 100 {
  n=split($1,m,"_")
  print m[n]
  next
} {
  n=split($1,m,"_")
  print m[n-1]
}' samples.txt > sra.txt

#individual based on id following adapter info (i.e., i7_*)
awk -v trim="NS.1712.001.NEBNext_dual_i7_" '{
  split($1,m,"-")
  gsub(trim,"",m[1])
  print "DFI_" m[1]
}' samples.txt > individual.txt

#rg combining id and "sra"
paste -d "_" individual.txt sra.txt | tail -n 102 > rg.txt

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
paste -d "\t" sra.txt ploidy.txt files.txt rg.txt instrument.txt individual.txt ftp.txt md5.txt > datatable.txt
rm sra.txt ploidy.txt files.txt rg.txt instrument.txt individual.txt ftp.txt md5.txt samples.txt
mv datatable.txt ${dtdir}/

cd ${rawdir}
for file in $(ls -1 ~/scratch/mg615512/linkage_data/*.gz) ; do
  ln -s "$file" .
done
