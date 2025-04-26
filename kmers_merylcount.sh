#!/bin/bash
#SBATCH --job-name=meryl
#SBATCH --partition=general
#SBATCH --qos=general
#SBATCH --cpus-per-task=12
#SBATCH --mem=100G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=meg8130@student.ubc.ca
#SBATCH -o meryl.%j.out
#SBATCH -e meryl.%j.err

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
merqury_out=${core}/merqury_out
sub_merqury=${merqury_out}/_submit_merqury.sh #this is the version of the script for use on a cluster
hifi=/seqdata/EBP/plant/Pseudotsuga_menziesii/allhifi_merged_trimmed.fastq.gz

meryl count k=21 threads=12 ${hifi} output ${merqury_out}/intDF_hifi_CBP.meryl
