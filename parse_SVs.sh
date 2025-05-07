#!/bin/bash
#SBATCH -J parse_SVs
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 4
#SBATCH --mem=30G
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

echo `hostname`

scratch=/scratch/msmith
mini=/home/FCAM/msmith/minigraph_out
all=${mini}/all_brokenscaffolds_noseq.bed
coastal=${mini}/coastal_path.bed
alternate=${mini}/alternate_path.bed
output=$1

echo -e "primary_contig\tprim_coord_diff\talternate_contig\talt_coord_diff\tcoastal_contig\tcoa_coord_diff\tshort_path\tlong_path" > ${output}
#cut the paths of each query through the graph from the call bed file
cut -f6 ${coastal} > ${scratch}/tmp_coa.bed
tmp_coa=${scratch}/tmp_coa.bed
cut -f6 ${alternate} > ${scratch}/tmp_alt.bed
tmp_alt=${scratch}/tmp_alt.bed

paste ${all} ${tmp_alt} ${tmp_coa} > ${scratch}/tmp_all.bed
paste "${all}" "${tmp_alt}" "${tmp_coa}" > "${scratch}/tmp_all.bed"
if [ $? -ne 0 ]; then
  echo "Error: Failed to paste files."
  exit 1
fi

tmp_all="${scratch}/tmp_all.bed"

#get field numbers for alt and coastal paths
coa_field=$(awk '{print NF}' "${tmp_all}" | head -n1)
alt_field=$((coa_field - 1))

while read -r line; do
  prim_con=$(echo "$line" | awk '{print $1}')
  short=$(echo "$line" | cut -f7)
  long=$(echo "$line" | cut -f8)
  prim_start=$(echo "$line" | cut -f2)
  prim_end=$(echo "$line" | cut -f3)
  prim_diff=$(echo "${prim_end} - ${prim_start}" | bc)
  # Process alternate path
  alt_field_val=$(echo "$line" | awk -v var="${alt_field}" '{print $var}')
  if [[ "${alt_field_val}" == '.' ]]; then
    alt_con='NA'
    alt_diff='NA'
  else
    alt_con=$(echo "${alt_field_val}" | awk -F ":" '{print $4}')
    alt_start=$(echo "${alt_field_val}" | awk -F ":" '{print $5}')
    alt_end=$(echo "${alt_field_val}" | awk -F ":" '{print $6}')
    alt_diff=$(echo "${alt_end} - ${alt_start}" | bc)
  fi
  # Process coastal path
  coa_field_val=$(echo "$line" | awk -v var="${coa_field}" '{print $var}')
  if [[ "${coa_field_val}" == '.' ]]; then
    coa_con='NA'
    coa_diff='NA'
  else
    coa_con=$(echo "${coa_field_val}" | awk -F ":" '{print $4}')
    coa_start=$(echo "${coa_field_val}" | awk -F ":" '{print $5}')
    coa_end=$(echo "${coa_field_val}" | awk -F ":" '{print $6}')
    coa_diff=$(echo "${coa_end} - ${coa_start}" | bc)
  fi
  # Write to output
  echo -e "${prim_con}\t${prim_diff}\t${alt_con}\t${alt_diff}\t${coa_con}\t${coa_diff}\t${short}\t${long}" >> "${output}"
done < "${tmp_all}"

# Clean up
rm "${tmp_all}"
  
  
  



