#!/bin/bash
#SBATCH -J busco
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 12
#SBATCH --mem=200G
#SBATCH -o ${log}/%x.%j.out
#SBATCH -e ${log}/%x.%j.err

set -e

echo "[M]: Host Name: `hostname`"

#variables
home=/home/FCAM/msmith
core=/core/projects/EBP/smith
scratch=/scratch/msmith
outdir=${core}/manual_curation_files
prim=${outdir}/interior_primary_final_mancur.fa
baseprim=$(basename ${prim})
alt=${core}/CBP_assemblyfiles/interior_alternate_final.fa

export PATH="${home}/scripts/post_asm_analysis:$PATH"
log=${core}/manual_curation_files/log

database=$1
date
echo "[M]: Beginning BUSCO analysis of ${baseprim} against database ${database}"
#Module files
source /home/FCAM/msmith/busco/.venv/bin/activate
module load blast/2.7.1 augustus/3.6.0 hmmer/3.3.2 R/4.2.2 java/17.0.2 bbmap/39.08 prodigal/2.6.3
export AUGUTUS_CONFIG_PATH="/core/projects/EBP/smith/busco/config"
threads="$(getconf _NPROCESSORS_ONLN)"
export PATH="/home/FCAM/msmith/R/x86_64-pc-linux-gnu-library/4.2:$PATH"
export PATH="/core/projects/EBP/smith/bin/miniprot:$PATH"
outbusco=${outdir}/busco

busco -c ${threads} -i ${prim} -m "genome" -f -l ${database} -o "prim_mancur_${database}" --out_path ${outbusco}
if [[ $? -eq 0 ]] ; then
echo "[M]: Done."
exit 0
else
echo "[E]: BUSCO run failed. Exit code $?"
fi
