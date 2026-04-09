#!/bin/bash
#SBATCH -J busco
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 10
#SBATCH --mem=84G
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

set -e

echo "[M]: Host Name: `hostname`"

#variables
home=/home/FCAM/msmith
core=/core/projects/EBP/smith
scratch=/scratch/msmith
outdir_prim=${home}/genome_annotation/busco_primary_annotation_allv
transcripts_prim=${core}/eviann/eviann_int_allvdata/interior_primary_mancur_masked_500kb.allvdata.transcripts.fa

database=$1
echo -e "`date`:[M]: Beginning BUSCO analysis of primary annotation against database ${database}.\n"
#Module files
source /home/FCAM/msmith/busco/.venv/bin/activate
module load blast/2.15.0 augustus/3.6.0 hmmer/3.4 R/4.2.2 java/22 bbmap/39.34 prodigal/2.6.3
export AUGUTUS_CONFIG_PATH="/core/projects/EBP/smith/busco/config"
threads="$(getconf _NPROCESSORS_ONLN)"
export PATH="/home/FCAM/msmith/R/x86_64-pc-linux-gnu-library/4.2:$PATH"
export PATH="/core/projects/EBP/smith/bin/miniprot:$PATH"
outbusco=${outdir_prim}

busco -c ${threads} -i ${transcripts_prim} -m "protein" -f -l ${database} -o "prim_annotation_${database}" --out_path ${outbusco}
