#!/bin/bash
#SBATCH -J build_rawfile
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

vcf=linkage_snp_calling_gatk_filtered_pass_biallelic_indels.vcf
raw=DFI_linkagemap_all.raw

python3 /home/FCAM/msmith/scripts/dfi_linkage_map/build_batchmap_inputfile.py \
"$vcf" "$raw"

bgzip "$vcf"
