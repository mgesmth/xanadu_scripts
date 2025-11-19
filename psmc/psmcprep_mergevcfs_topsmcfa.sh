#!/bin/bash
#SBATCH -J psmc_prep_mergetopsmcfa
#SBATCH -p himem2
#SBATCH -q himem
#SBATCH -c 36
#SBATCH --mem=1200G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=meg8130@student.ubc.ca
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

set -e
date
echo "[M]: Host Name: `hostname`"

#Module FILES
module load vcftools/0.1.16
module load psmc/0.6.5
module load bcftools/1.20
module load tabix/0.2.6

#Variables
home=/home/FCAM/msmith
core=/core/projects/EBP/smith
scratch=/scratch/msmith
vcf_dir=${scratch}/hifi_vcfs
out_vcf=${scratch}/hifialn_merged.vcf.gz
out_vcf_s=${scratch}/hifialn_merged.s.vcf.gz
out_fastq=${scratch}/hifialn_merged.fastq.gz
out_psmcfa=${home}/psmc/hifialn_merged.psmcfa

#concatenate split vcf files
cd ${vcf_dir}
ls -1 *.vcf.gz > vcf_files.txt
bcftools concat --threads 36 -a -d -O "z" -f vcf_files.txt -o "$out_vcf"
if [[ $? -ne 0 ]] ; then
  echo "Concatenation of split vcfs failed. Exit code $?"
  date
  exit 1
fi

#sort concatenated vcf file
cd ..
rm -r vcfs
bcftools sort -m 1200G -T ${scratch} -O "z" -o "$out_vcf_s" "$out_vcf"
if [[ $? -eq 0 ]] ; then
  rm "$out_vcf"
  #Transform sorted VCF into fastq file format
  vcfutils.pl vcf2fq -d 10 -D 64 "$out_vcf_s" | gzip -c > "$out_fastq"
  if [[ $? -eq 0 ]] ; then
    rm ${out_vcf_s}
    #Create psmcfa (input for psmc)
		fq2psmcfa -q20 "$out_fastq" > "$out_psmcfa"
    if [[ $? -eq 0 ]] ; then
      echo "[M]: PSMCFA file created. Bye!"
      exit 0
    else
      echo "[E]: Creation of PSMCFA file failed. Exiting."
      exit 1
    fi
  else
		echo "[E]: Conversion to fastq failed. Exiting."
		exit 1
	fi
else
  echo "[E]: Sorting of concatenated VCF failed. Exiting."
  exit 1
fi
