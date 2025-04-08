#!/bin/bash
#SBATCH --job-name=juicer
#SBATCH --partition=general
#SBATCH --qos=general
#SBATCH --cpus-per-task=36
#SBATCH --mem=256G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=meg8130@student.ubc.ca
#SBATCH -o juicer.%j.out
#SBATCH -e juicer.%j.err

echo `hostname`

#Define Directory Structure ---
core=/core/projects/EBP/smith
home=/home/FCAM/msmith
scratch=/scratch/msmith
juicedir=${core}/juicedir
scripts=${juicedir}/scripts
assembly=${
enzyme="Arima"

module load bwa/0.7.17

cd ${juicedir}/references
bwa index $assembly

module load python/3.8.1
module load juicer/1.8.9

##Generate restriction site positions ---
cd ${juicedir}/restriction_sites
python3 ${scripts}/generate_site_positions.py $enzyme $assembly
#NOTE: I modified the generate_site_positions script to recognize the Arima sites
#they were in another version of the script on the Juicer github, but not in 
#this script. I also added my genome code, intDF.

if {$? -eq 0}; then
awk 'BEGIN{OFS="\t"}{print $1, $NF}' intDF_arima.txt > intDF.chrom.sizes
mv intDF.chrom.sizes ../work
else 
exit
fi

##Run Juicer ---
cd ..
${scripts}/juicer.sh -d ${juicedir}/work -p ${juicedir}/work/intDF.chrom.sizes \
-y ${juicedir}/restriction_sites/intDF_arima.txt -z $assembly -D ${juicedir} \
-t 36 -A msmith
#-d option specifies fastq hic files
