#!/bin/bash
#SBATCH -J busco
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 10
#SBATCH --mem=84G
#SBATCH -o /core/projects/EBP/smith/manual_curation_files/log/%x.%j.out
#SBATCH -e /core/projects/EBP/smith/manual_curation_files/log/%x.%j.err

set -e

echo "[M]: Host Name: `hostname`"

#variables
home=/home/FCAM/msmith
core=/core/projects/EBP/smith
scratch=/scratch/msmith
outdir_prim=${home}/genome_annotation/busco_primary_annotation
outdir_alt=${home}/genome_annotation/busco_alternate_annotation
transcripts_prim=${core}/eviann/eviann_justint/interior_primary_mancur_masked_500kb.justint.proteins.fa
transcripts_alt=${core}/eviann/eviann_alt_justint/interior_alternate_masked.fa.proteins.fasta

database=$1
echo -e "`date`:[M]: Beginning BUSCO analysis of primary annotation against database ${database}.\n"
#Module files
source /home/FCAM/msmith/busco/.venv/bin/activate
module load blast/2.7.1 augustus/3.6.0 hmmer/3.3.2 R/4.2.2 java/17.0.2 bbmap/39.08 prodigal/2.6.3
export AUGUTUS_CONFIG_PATH="/core/projects/EBP/smith/busco/config"
threads="$(getconf _NPROCESSORS_ONLN)"
export PATH="/home/FCAM/msmith/R/x86_64-pc-linux-gnu-library/4.2:$PATH"
export PATH="/core/projects/EBP/smith/bin/miniprot:$PATH"
outbusco=${outdir_prim}

busco -c ${threads} -i ${transcripts_prim} -m "protein" -f -l ${database} -o "prim_annotation_${database}" --out_path ${outbusco}

echo -e "\n`date`:[M]: Done BUSCO analysis of primary annotation. Beginning alternate annotation against ${database}.\n"
outbusco=${outdir_alt}

busco -c ${threads} -i ${transcripts_alt} -m "protein" -f -l ${database} -o "alt_annotation_${database}" --out_path ${outbusco}
