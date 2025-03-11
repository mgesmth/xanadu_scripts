#!/bin/bash
#SBATCH --job-name=meryl
#SBATCH --partition=general
#SBATCH --qos=general
#SBATCH --cpus-per-task=36
#SBATCH --mem=256G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=meg8130@student.ubc.ca
#SBATCH -o meryl.%j.out
#SBATCH -e meryl.%j.err

module load meryl/1.4.1
module load merqury/1.3

echo `hostname`
echo "for this job, only meryl - next time running merqury"

#Directory structure---
home=/home/FCAM/msmith
core=/core/projects/EBP/smith
primasm=${core}/CBP_assemblyfiles/interior_primary_final.fa
altasm=${core}/CBP_assemblyfiles/interior_alternate_final.fa
merqury_out=${core}/merqury_out
merqury${merqury_out}/_submit_merqury.sh #this is the version of the script for use on a cluster
hifi=${home}/hifi_data


#first have to find the right kmer stats. Ran with best_k.sh (16Gb, 0.001) and said ~22-mers
meryl count k=22 threads=36 $hifi output ${merqury_out}/intDF_hifi_CBP.meryl
#$merqury ${merqury_out}/intDF_hifi_CBP.meryl $primasm $altasm ${merqury_out}/intDF_CBP_merq


