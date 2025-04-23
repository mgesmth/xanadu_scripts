#!/bin/bash
#SBATCH -p himem
#SBATCH -q himem
#SBATCH -c 8
#SBATCH --mem=150G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=meg8130@student.ubc.ca
#SBATCH -o restrict.%j.out
#SBATCH -e restrict.%j.err

module load python/3.10.1
module load pairtools/0.2.2

core=/core/projects/EBP/smith
scratch=/scratch/msmith
restr=${core}/juicer_intDF011/restriction_sites/intDF011_Arima.bed
pairs=${core}/juicer_intDF011/intDF011.nodups.pairs

pairtools restrict -f "${restr}" -o "${core}/juicer_intDF011/intDF011.nodups_frag.pairs" "${pairs}"
