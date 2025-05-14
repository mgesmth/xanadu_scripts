#!/bin/bash
#SBATCH -J busco
#SBATCH -p general
#SBATCH -q general
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 12
#SBATCH --mem=200G
#SBATCH --array=[0-2]%3
#SBATCH --mail-type=ALL
#SBATCH --mail-user=meg8130@student.ubc.ca
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

echo "[M]: Hostname: `hostname`"

source /home/FCAM/msmith/busco/.venv/bin/activate
module load blast/2.7.1 augustus/3.6.0 hmmer/3.3.2 R/4.2.2 java/17.0.2 bbmap/39.08 prodigal/2.6.3
#Augustus needs a writable config path to work - copied from the Augustus module on Xanadu
export AUGUTUS_CONFIG_PATH="/core/projects/EBP/smith/busco/config"
#My R library
export PATH="/home/FCAM/msmith/R/x86_64-pc-linux-gnu-library/4.2:$PATH"
#A downloaded version of miniprot: the one on Xanadu seems coorrupted
export PATH="/core/projects/EBP/smith/bin/miniprot:$PATH"

home=/home/FCAM/msmith
core=/core/projects/EBP/smith
dbs=($(echo -e "eukaryota_odb12\nembryophyta_odb12\nviridiplantae_odb12"))

/home/FCAM/msmith/scripts/run_busco.sh -t 28 -i "${mine}" -m "${mode}" -l "${db1}" -o "${out1}"

#names for db for this task:
db="${dbs[$SLURM_ARRAY_TASK_ID]}"
prim=${core}/CBP_assemblyfiles/interior_primary_final.fa
alt=${core}/CBP_assemblyfiles/interior_alternate_final.fa
coastal=${core}/coastal/coastalDF_scaffrenamed_sorted.fa
mode="genome"
out1="${home}/busco/prim_${db}"
out2="${home}/busco/alt_${db}"
out3="${home}/busco/coa_${db}"

#/home/FCAM/msmith/scripts/run_busco.sh -t 12 -i "${prim}" -m "${mode}" -l "${db}" -o "${out1}"
#/home/FCAM/msmith/scripts/run_busco.sh -t 12 -i "${alt}" -m "${mode}" -l "${db}" -o "${out2}"
/home/FCAM/msmith/scripts/run_busco.sh -t 12 -i "${coastal}" -m "${mode}" -l "${db}" -o "${out3}"
