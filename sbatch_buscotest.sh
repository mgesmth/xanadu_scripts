#!/bin/bash
#SBATCH -J busco_embryo
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 4
#SBATCH --mem=20G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=meg8130@student.ubc.ca
#SBATCH -o busco_test.%j.out
#SBATCH -e busco_test.%j.err

echo `hostname`


module load bbmap/39.08
module load blast/2.7.1
export AUGUTUS_CONFIG_PATH="/core/projects/EBP/smith/busco/config"
module load augustus/3.6.0 
module load miniprot/0.7
module load sepp/4.5.1
module load hmmer/3.3.2
module load R/4.2.2
export PATH="/home/FCAM/msmith/R/x86_64-pc-linux-gnu-library/4.2:$PATH"
export PATH="/home/FCAM/msmith/scripts:$PATH"
module load python/3.8.1

source /home/FCAM/msmith/busco/.venv/bin/activate\

core=/core/projects/EBP/smith
prim=${core}/CBP_assemblyfiles/interior_primary_final.fa
alt=${core}/CBP_assemblyfiles/interior_alternate_final.fa
mine=${core}/scaffold/withpairtools_noerrorcorrect/intDF011_scaffolds_final.fa
coastal=${core}/coastal/coastalDF_scaffrenamed_sorted.fa
test=${core}/busco/genome.fna
mode="geno"
db="eukaryota_odb12"
out=${core}/busco/test

run_busco.sh -t 8 -i "${test}" -m "${mode}" -l "${db}" -o "${out}"
