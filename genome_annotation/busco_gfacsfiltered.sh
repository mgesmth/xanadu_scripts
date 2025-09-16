#!/bin/bash
#SBATCH -J BUSCO_gfacs_filtered
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 12
#SBATCH --mem=64G
#SBATCH --array=[0-2]
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

set -e
date
echo "[M]: Host Name: `hostname`"

home=/home/FCAM/msmith
core=/core/projects/EBP/smith
trme=${home}/transcriptome/01_transcriptome_alignment
gfacs_filt=${trme}/gFACs/filtered
#protein fasta from gFACs output
prot_fa=${gfacs_filt}/intdf137_filtered_genes.fasta.faa
busco_dir=${trme}/busco

dbs=($(echo -e "eukaryota_odb12\nembryophyta_odb12\nviridiplantae_odb12"))
db=${dbs[$SLURM_ARRAY_TASK_ID]}
out="${busco_dir}/${db}"

#Module files
module load busco/5.7.0 blast/2.7.1 augustus/3.6.0 hmmer/3.3.2 R/4.2.2 java/17.0.2 bbmap/39.08 prodigal/2.6.3
export AUGUTUS_CONFIG_PATH="${core}/busco/config"
export PATH="${home}/R/x86_64-pc-linux-gnu-library/4.2:$PATH"
export PATH="${core}/bin/miniprot:$PATH"

${home}/scripts/run_busco.sh -t 12 -m "proteins" -l "$db" -o "$out" -i "$prot_fa"

date
echo "[M]: Done."
