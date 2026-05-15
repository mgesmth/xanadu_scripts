#!/bin/bash
#SBATCH --job-name="10b.batchmapfile"
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

filt_vcf="10b_filt_vcfs"
scripts="01_scripts"
batchmap="11_batchmap"
in_vcf_std=$filt_vcf/${DATASET}_gatk_filtered_std_pass_biallelic_indels.vcf
if [[ ! -f ${in_vcf_std} && -f ${in_vcf_std}.gz ]] ; then
  bgzip -d ${in_vcf_std}.gz
elif [[ ! -f ${in_vcf_std} && ! -f ${in_vcf_std}.gz ]] ; then
  echo "[E]: Standard in_vcf not found. Exiting."
  exit 1
fi

in_vcf_str=$filt_vcf/${DATASET}_gatk_filtered_stringent_pass_biallelic_indels.vcf
if [[ ! -f ${in_vcf_str} && -f ${in_vcf_str}.gz ]] ; then
  bgzip -d ${in_vcf_str}.gz
elif [[ ! -f ${in_vcf_str} && ! -f ${in_vcf_str}.gz ]] ; then
  echo "[E]: Stringent in_vcf not found. Exiting."
  exit 1
fi

ind_missingness=0.4
snp_missingness=0.1
gq_std=20
gq_str=30
out_vcf_std=$filt_vcf/${DATASET}_gatk_filtered_std_pass_biallelic_indels_missingness${snp_missingness}_gq${gq_std}.vcf
out_vcf_str=$filt_vcf/${DATASET}_gatk_filtered_stringent_pass_biallelic_indels_missingness${snp_missingness}_gq${gq_str}.vcf

echo -e "[M]: Running missingness filter on standard SNP set with SNP missingness threshold ${snp_missingness}, sample missingness threshold ${snp_missingness}, and genotype quality threshold ${gq_std}.\n"

python3 ${scripts}/filter_GQ_missingness_maternal.py \
${snp_missingness} ${ind_missingness} ${gq_std} "$in_vcf_std" "$out_vcf_std"

echo -e "[M]: Running missingness filter on stringent SNP set with SNP missingness threshold ${snp_missingness}, sample missingness threshold ${snp_missingness}, and genotype quality threshold ${gq_str}.\n"

python3 ${scripts}/filter_GQ_missingness_maternal.py \
${snp_missingness} ${ind_missingness} ${gq_str} "$in_vcf_str" "$out_vcf_str"

#####
#create batchmap input file

bm_std=$batchmap/${DATASET}_batchmap_standard.txt
bm_str=$batchmap/${DATASET}_batchmap_stringent.txt

echo -e "\n[M]:Building standard batchmap input file.\n"
python3 ${scripts}/build_batchmap_inputfile_batchmap.py \
"$out_vcf_std" "$bm_std"
echo "[M]: Done."
echo -e "\n[M]:Building stringent batchmap input file.\n"
python3 ${scripts}/build_batchmap_inputfile_batchmap.py \
"$out_vcf_str" "$bm_str"

mv missingness_per* ${filt_vcf}
mv inds_passed* ${filt_vcf}

echo "[M]: Done! Check your files."
