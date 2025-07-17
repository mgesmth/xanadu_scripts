#!/bin/bash
#SBATCH -J prep_forjuicer
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 12
#SBATCH --mem=128G
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

set -e

date
echo "[M]: Host Name: `host name`"

module load bwa/0.7.17
module load samtools/1.19
module load python/3.8.1
core=/core/projects/EBP/smith
juicedir=${core}/juicer_formanualcur
export PATH="${juicedir}/scripts:$PATH"
prim=${juicedir}/references/interior_primary_final.fa
prim_name=$(basename ${prim})
gid="intdf137"
enzyme="Arima"

#echo "[M]: Generating BWA index for ${prim_name}"
#bwa index ${prim}
#if [[ $? -eq 0 ]] ; then
  date
#  echo "[M]: Index made. Moving onto site_positions file."
  cd ${juicedir}/restriction_sites
  python ${juicedir}/scripts/generate_site_positions.py "$enzyme" "$gid" "$prim"
  if [[ $? -eq 0 ]] ; then
    date
    echo "[M]: site_positions file generated. Bye."
    exit 0
  else
    echo "[E]: site_positions file failed to generate. Exit code $?"
    exit 1
  fi
#else
#  echo "[E]: BWA index generation failed. Exit code $?"
#  exit 1
#fi
