#!/bin/bash
#SBATCH -J splitasm
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 6
#SBATCH --mem=30G
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

set -e
echo "[M]: Host Name: `hostname`"

home=/home/FCAM/msmith
core=/core/projects/EBP/smith
scratch=/scratch/msmith
primary=${core}/3DDNA/mancur2/interior_primary_final_mancur2.fa
splitdir=${home}/mancur_splitasm

module load samtools/1.19
module load seqkit/2.10.0

#find where the first 20 scaffolds end in fasta file and send to tmp 20 scaffold file, and all else to another file
awk '{if ($1 ~ "HiC_scaffold_21") { ; print NR-1 ; exit }}' ${primary} > linenum.tmp
linenum=$(tr -d '\n' < linenum.tmp)
head -n ${linenum} ${primary} > ${home}/20_tmp.fa
totallen=$(wc -l ${primary} | cut -d ' ' -f1)
tailnum=$(echo $((${totallen}-${linenum})))
tail -n ${tailnum} ${primary} > ${home}/allelse_tmp.fa
rm linenum.tmp

#split rest of scaffolds into above 1Mb and below 1Mb - will be run in separate slurm arrays with different resource requests
if [[ ! -f "${home}/allelse_tmp.fa.fai" ]] ; then
  samtools faidx "${home}/allelse_tmp.fa"
fi
awk '{
  if ($2 > 1000000) { 
    next
  } else if ($2 < 1000000) {
    #print the name of the scaffold that is the first to be less than a Mb long
    print $1
    exit
  }
}' "${home}/allelse_tmp.fa.fai" > first_small_scaffold.tmp
scaffnum=$(tr -d '\n' < first_small_scaffold.tmp)
#get the line number in the fasta file corresponding to this scaffold; we need all line preceeding it for >1Mb scaffolds
awk -v scaffnum="$scaffnum" '{if ($1 ~ scaffnum) { ; print NR-1 ; exit }}' ${home}/allelse_tmp.fa > linenum1.tmp
linenum1=$(tr -d '\n' < linenum1.tmp)
head -n ${linenum1} ${home}/allelse_tmp.fa > ${home}/above1Mb_tmp.fa
totallen1=$(wc -l ${home}/allelse_tmp.fa | cut -d ' ' -f1)
#get the number of the remaining lines ; these are the 
tailnum1=$(echo $((${totallen1}-${linenum1})))
tail -n ${tailnum1} ${home}/allelse_tmp.fa > ${scratch}/below1Mb_tmp.fa
rm ${home}/allelse_tmp.fa* linenum1.tmp

#split the tmp fasta files into 20 parts for each scaffold
seqkit split -s 1 ${home}/20_tmp.fa --by-size-prefix "interior_primary_mancur_scaffold" -O ${splitdir}/first_20
rm ${home}/20_tmp.fa

#for the rest - will have to rename scaffolds
seqkit split -s 1 ${home}/above1Mb_tmp.fa --by-size-prefix "interior_primary_mancur_scaffold" -O ${splitdir}/above_1Mb
cd ${splitdir}/above_1Mb
ls -1 * | while read -r file ; do
  no_suf=${file/.fa/}
  #scaffold number will be the original number plus 20 (since the first 20 are already split)
  new_name=$(echo "$no_suf" | awk '{split($0,m,"scaffold") ; print "interior_primary_mancur_scaffold"m[2]+20".fa"}')
  mv ${file} ${new_name}
done

samtools faidx ${home}/above1Mb_tmp.fa
#Get the number of the last above 1Mb scaffold - this will be added to the split scaffold names
last_above=$(tail -n1 ${home}/above1Mb_tmp.fa | awk '{split($1,m,"_") ; print m[3]}')
seqkit split -s 1 ${home}/below1Mb_tmp.fa --by-size-prefix "interior_primary_mancur_scaffold" -O ${splitdir}/below_1Mb
cd ${splitdir}/below_1Mb
ls -1 * | while read -r file ; do
  no_suf=${file/.fa/}
  new_name=$(echo "$no_suf" | awk -v last=${last_above} '{split($0,m,"scaffold") ; print "interior_primary_mancur_scaffold"m[2]+last".fa"}')
    mv ${file} ${new_name}
done
rm ${home}/above1Mb_tmp.fa* ${home}/below1Mb_tmp.fa



