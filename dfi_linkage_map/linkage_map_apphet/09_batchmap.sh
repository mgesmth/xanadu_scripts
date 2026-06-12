#!/bin/bash
#SBATCH --job-name="9.batchmapfile"
#SBATCH -o 98_log_files/%x_%j.out
#SBATCH -e 98_log_files/%x_%j.err
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=16G

echo "[M]: Host Name: `hostname`"
set -e

module load python/3.13.11-gcc-11.4.0-kifh66l tabix/0.2.6
source /home/FCAM/msmith/python_venv/bin/activate

filt_vcf="09_filt_vcfs"
scripts="01_scripts"
batchmap="10_batchmap"
in_vcf=$filt_vcf/${DATASET}_filtered_pass_biallelic_indels.vcf
if [[ ! -f ${in_vcf} && -f ${in_vcf}.gz ]] ; then
  bgzip -d ${in_vcf}.gz
elif [[ ! -f ${in_vcf} && ! -f ${in_vcf}.gz ]] ; then
  echo "[E]: in_vcf not found. Exiting."
  exit 1
fi

ind_missingness=0.5
snp_missingness=0.1
gq=30
out_vcf=$filt_vcf/${DATASET}_filtered_pass_biallelic_indels_missingness${snp_missingness}_gq${gq_std}.vcf

echo -e "[M]: Running missingness filter with SNP missingness threshold ${snp_missingness}, sample missingness threshold ${snp_missingness}, and genotype quality threshold ${gq_std}.\n"

python3 ${scripts}/filter_GQ_missingness_maternal.py \
${snp_missingness} ${ind_missingness} ${gq} "$in_vcf" "$out_vcf"

#####
#create batchmap input file

bm=$batchmap/${DATASET}_batchmap.txt

echo -e "\n[M]:Building batchmap input file.\n"
python3 ${scripts}/build_batchmap_inputfile_batchmap.py \
"$out_vcf" "$bm"

echo "[M]: Done! Check your files."
