#!/bin/bash
#SBATCH -J filter
#SBATCH -D /core/projects/EBP/smith/linkage_snp_calling/10b_filt_vcfs
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 12
#SBATCH --mem=36G
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

echo "[M]: Host Name: `hostname`"
set -e

module load python/3.13.11-gcc-11.4.0-kifh66l tabix/0.2.6
source /home/FCAM/msmith/python_venv/bin/activate

bgzip -d linkage_snp_calling_gatk_filtered_std_pass_biallelic_indels.vcf.gz

in_vcf=linkage_snp_calling_gatk_filtered_std_pass_biallelic_indels.vcf
out_vcf_prx=linkage_snp_calling_gatk_filtered_std_pass_biallelic_indels_missingness

python3 /home/FCAM/msmith/scripts/dfi_linkage_map/filter_GQ_missingness_maternal.py \
0.3 0.5 30 "$in_vcf" "$out_vcf_prx"

bgzip "$in_vcf"
