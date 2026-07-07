#!/bin/bash
#SBATCH --job-name="10b.batchmapfile"
#SBATCH -o 98_log_files/%x_%j.out
#SBATCH -e 98_log_files/%x_%j.err
#SBATCH -c 8
#SBATCH --mem=16G

echo "[M]: Host Name: `hostname`"
set -e

module load python/3.13.11-gcc-11.4.0-kifh66l tabix/0.2.6
source /home/FCAM/msmith/python_venv/bin/activate

DATASET=$1

filt_vcf="09_filt_vcfs"
scripts="01_scripts"
batchmap="10_batchmap"
interval=10000

#####
#create batchmap input file
vcf=${filt_vcf}/${DATASET}_filtered_pass_biallelic_indels_missingness0.25_gq99.vcf
bm=$batchmap/DFI_linkagemap_markers_miss${snp_missingness}.txt

echo -e "\n[M]:Building batchmap input file.\n"
python3 ${scripts}/build_batchmap_inputfile_batchmap.py \
"$vcf" "$bm" 10000

bgzip $vcf 
tabix -p vcf ${vcf}.gz

echo "[M]: Done! Check your files."
