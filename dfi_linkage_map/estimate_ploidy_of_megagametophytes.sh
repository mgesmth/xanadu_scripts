#!/bin/bash
#SBATCH -J kmer_ploidy
#SBATCH -p general
#SBATCH -q general
#SBATCH -D /core/projects/EBP/smith/linkage_snp_calling_unsplit/ploidy_estimation
#SBATCH -c 4
#SBATCH --mem=10G
#SBATCH --mail-type=ALL
#SBATCH --array=[0-101]
#SBATCH --mail-user=meg8130@student.ubc.ca
#SBATCH -o /core/projects/EBP/smith/linkage_snp_calling_unsplit/ploidy_estimation/log/%x.%A.%a.out
#SBATCH -e /core/projects/EBP/smith/linkage_snp_calling_unsplit/ploidy_estimation/log/%x.%A.%a.err

echo "[M]: Host Name: `hostname`"
set -e

core=/core/projects/EBP/smith
topdir=${core}/linkage_snp_calling_unsplit
dir=${topdir}/ploidy_estimation
trimdir=${topdir}/05_trimmed_data

module load meryl/1.4.1 r/4.5.2-gcc-11.4.0-ware24q
export PATH="/home/FCAM/msmith/R/x86_64-pc-linux-gnu-library/4.2:$PATH"
export PATH="/core/projects/EBP/smith/bin/genomescope2.0:$PATH"

#R1s.txt is a list of the trimmed R1 fastqs (no dir structure)
array=($(cat R1s.txt))
file=${array[$SLURM_ARRAY_TASK_ID]}
cd $dir
name=${file%.R1.trimmed.fastq.gz}
file_r2=$(echo "$file" | sed 's/.R1/.R2/')
if [[ ! -d "$name" ]] ; then
	mkdir $name
fi
cd $name 
echo "[M]: Counting ${name} kmers..."
meryl count threads=4 k=21 ${trimdir}/${file} output ${name}.R1.meryl
meryl count threads=4 k=21 ${trimdir}/${file_r2} output ${name}.R2.meryl
meryl union-sum ${name}.R1.meryl ${name}.R2.meryl output ${name}.meryl
meryl histogram threads=12 k=21 ${name}.meryl > ${name}.meryl.hist 
if [[ "$name" == *"libP"* ]] ; then
    genomescope.R -i ${name}.meryl.hist -o . -k 21 -p 2
else
    genomescope.R -i ${name}.meryl.hist -o . -k 21 -p 1
fi
echo "[M]: Done."

	


