#!/bin/bash
#SBATCH -J busco
#SBATCH -p himem
#SBATCH -q himem
#SBATCH -c 20
#SBATCH --mem=300G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=meg8130@student.ubc.ca
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

echo `hostname`

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
prim=${core}/CBP_assemblyfiles/interior_primary_final.fa
alt=${core}/CBP_assemblyfiles/interior_alternate_final.fa
mine=${core}/scaffold/withpairtools_noerrorcorrect/intDF011_scaffolds_final.fa
coastal=${core}/coastal/coastalDF_scaffrenamed_sorted.fa
mode="genome"
db1="viridiplantae_odb12"
db2="eukaryota_odb12"
out1=${home}/busco/intDF011_viridiplantae
out2=${home}/busco/intDF011_eukaryota

/home/FCAM/msmith/scripts/run_busco.sh -t 18 -i "${mine}" -m "${mode}" -l "${db1}" -o "${out1}"
#/home/FCAM/msmith/scripts/run_busco.sh -t 18 -i "${mine}" -m "${mode}" -l "${db2}" -o "${out2}"
