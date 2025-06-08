#!/bin/bash
#SBATCH -J psmc_prep
#SBATCH -p himem2
#SBATCH -q himem
#SBATCH -c 24
#SBATCH --mem=600G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=meg8130@student.ubc.ca
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

echo "[M]: Host Name: `hostname`"

home=/home/FCAM/msmith
scratch=/scratch/msmith
core=/core/projects/EBP/smith
prim=${core}/CBP_assemblyfiles/interior_primary_final.fa
hifi_split=${scratch}/hifi_out
hifi_merge=${scratch}/hifialn_merged.bam 

module load samtools/1.20
module load psmc/0.6.5
module load bcftools/1.20

#based on the example from the lh3/psmc github page

if [[ ! -f "${prim}.fai" ]] ; then
  samtools faidx "$prim"
fi

#set read depth min max (-d,-D) to 1/3 avg. read depth and 2x avg. read depth
bcftools mpileup -C50 -f "$prim" "$hifi_merge" | bcftools call -c -Ov | \
vcfutils.pl vcf2fq -d 10 -D 64 | gzip > ${scratch}/hifialn_merged.fastq.gz
if [[ $? -eq 0 ]] ; then
  echo ""
  echo "[M]: Fastq conversion complete. Moving on to psmcfa file creation."
  echo ""
else
  echo ""
  echo "[E]: Fastq conversion failed. Exiting."
  exit 1
fi

fq2psmcfa -q20 ${scratch}/hifialn_merged.fastq.gz > ${home}/hifialn_merged.psmcfa

