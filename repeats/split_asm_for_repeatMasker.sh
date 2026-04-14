#!/bin/bash
#SBATCH -J splitasm
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 10
#SBATCH --mem=30G

set -e
echo "[M]: Host Name: `hostname`"

home=/home/FCAM/msmith
core=/core/projects/EBP/smith
scratch=/scratch/msmith
primary=$1
splitdir=${home}/repeats_round2
module load samtools/1.19
module load seqkit/2.10.0

#find where the first 20 scaffolds end in fasta file and send to tmp 20 scaffold file, and all else to another file
awk '{if ($1 ~ "HiC_scaffold_21") { ; print NR-1 ; exit }}' ${primary} > linenum.tmp
linenum=$(tr -d '\n' < linenum.tmp)
head -n ${linenum} ${primary} > 20_tmp.fa
totallen=$(wc -l ${primary} | cut -d ' ' -f1)
tailnum=$(echo $((${totallen}-${linenum})))
tail -n ${tailnum} ${primary} > allelse_tmp.fa
rm linenum.tmp

#split rest of scaffolds into above 1Mb and below 1Mb - will be run in separate slurm arrays with different resource requests
if [[ ! -f "allelse_tmp.fa.fai" ]] ; then
  samtools faidx allelse_tmp.fa
fi
awk '{
  if ($2 > 1000000) {
    next
  } else if ($2 < 1000000) {
    #print the name of the scaffold that is the first to be less than a Mb long
    print $1
    exit
  }
}' allelse_tmp.fa.fai > first_small_scaffold.tmp
scaffnum=$(tr -d '\n' < first_small_scaffold.tmp)
#get the line number in the fasta file corresponding to this scaffold; we need all line preceeding it for >1Mb scaffolds
awk -v scaffnum="$scaffnum" '{if ($1 ~ scaffnum) { ; print NR-1 ; exit }}' allelse_tmp.fa > linenum1.tmp
linenum1=$(tr -d '\n' < linenum1.tmp)
head -n ${linenum1} allelse_tmp.fa > above1Mb_tmp.fa
totallen1=$(wc -l allelse_tmp.fa | cut -d ' ' -f1)
#get the number of the remaining lines ; these are the
tailnum1=$(echo $((${totallen1}-${linenum1})))
tail -n ${tailnum1} allelse_tmp.fa > below1Mb_tmp.fa
rm allelse_tmp.fa* linenum1.tmp first_small_scaffold.tmp

#split the tmp fasta files into 20 parts for each scaffold
seqkit split -s 1 20_tmp.fa --by-size-prefix "interior_primary_mancur_scaffold_" -O first_20
rm 20_tmp.fa
cd first_20 && ls -1 *.fa > first20.txt
cd ${splitdir}
#for the rest - will have to rename scaffolds
seqkit split -s 1 above1Mb_tmp.fa --by-size-prefix "interior_primary_mancur_scaffold_" -O above_1Mb
cd above_1Mb
ls -1 * > above.txt
mkdir tmp
cat above.txt | while read -r file ; do
no_suf=${file/.fa/}
#scaffold number will be the original number plus 20 (since the first 20 are already split)
new_name=$(echo "$no_suf" | awk '{split($0,m,"scaffold_") ; print "interior_primary_mancur_scaffold_" m[2]+20 ".fa"}')
mv ${file} tmp/${new_name}
done
mv tmp/*.fa .
rm -r tmp/
ls -1 *.fa > above1Mb.txt
cd ${splitdir}

samtools faidx above1Mb_tmp.fa
#Get the number of the last above 1Mb scaffold - this will be added to the split scaffold names
last_above=$(($(tail -n1 above_1Mb/above.txt | sed 's/.fa//g' | cut -f5 -d "_")+20))
seqkit split -s 1 below1Mb_tmp.fa --by-size-prefix "interior_primary_mancur_scaffold_" -O below_1Mb
cd below_1Mb
ls -1 *.fa > below.txt
mkdir tmp
for file in $(cat below.txt); do
no_suf=${file/.fa/}
new_name=$(echo "$no_suf" | awk -v last=${last_above} '{split($0,m,"scaffold_") ; print "interior_primary_mancur_scaffold_" m[2]+last ".fa"}')
mv ${file} tmp/${new_name}
done
mv tmp/*.fa .
rm -r tmp/
ls -1 *.fa > below1Mb.txt
cd ${splitdir}
rm above1Mb_tmp.fa* below1Mb_tmp.fa


echo ">> Done Splitting Assembly!"
