#!/bin/bash
#SBATCH --job-name=merqury
#SBATCH --partition=general
#SBATCH --qos=general
#SBATCH --cpus-per-task=1
#SBATCH --mem=2G
#SBATCH -d afterok:9030334
#SBATCH -o merqury_intDF011.%j.out
#SBATCH -e merqury_intDF011.%j.err

module load R/4.2.2
export PATH="/home/FCAM/msmith/R/x86_64-pc-linux-gnu-library/4.2:$PATH"
module load meryl/1.4.1
module load merqury/1.3

echo `hostname`

#Directory structure---
home=/home/FCAM/msmith
core=/core/projects/EBP/smith
primasm=${core}/CBP_assemblyfiles/interior_primary_final.fa
altasm=${core}/CBP_assemblyfiles/interior_alternate_final.fa
mine=${core}/scaffold/withpairtools_noerrorcorrect/intDF011_scaffolds_final.fa
merqury_out=${core}/merqury_out
sub_merqury=${merqury_out}/_submit_merqury.sh #this is the version of the script for use on a cluster
hifi=/seqdata/EBP/plant/Pseudotsuga_menziesii/allhifi_merged_trimmed.fastq.gz

#NOTE: it seems meryl/merqury cannot follow symlinks.
mkdir /scratch/msmith/merqury_out

${sub_merqury} ${merqury_out}/intDF_hifi_CBP.meryl ${mine} /scratch/msmith/merqury_out/intDF011_merq
