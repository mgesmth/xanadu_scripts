#!/bin/bash
#SBATCH --partition=general
#SBATCH --qos=general
#SBATCH --cpus-per-task=12
#SBATCH --mem=150G
#SBATCH --mail-user=meg8130@student.ubc.ca
#SBATCH --mail-type=ALL
#SBATCH -o fastp.%j.out
#SBATCH -e fastp.%j.err

module load fastp/0.23.2

home=/home/FCAM/msmith
scratch=/scratch/msmith
adapters=${home}/pacbio_adapters.fa
hifi=${home}/hifi_data

fastp -V -G --adapter_fasta $adapters -i $hifi -o ${scratch}/intDF_allhifi_trim.fastq.gz
