#!/bin/bash
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 4
#SBATCH --mem=40G
#SBATCH --mail-type=END
#SBATCH --mail-user=meg8130@student.ubc.ca
#SBATCH -o sites2bed.%j.out
#SBATCH -e sites2bed.%j.err

restrdir=/core/projects/EBP/smith/juicer_intDF011/restriction_sites
sites=${restrdir}/intDF011_Arima.txt
out="${restrdir}/intDF011_Arima.bed"

#From chatGPT - bless
awk '{
    chrom = $1;
    for (i = 2; i <= NF; i++) {
        start = (i == 2) ? 0 : $(i - 1);
        end = $i;
        frag_id = i - 2;
        print chrom "\t" start "\t" end "\t" frag_id;
    }
}' "${sites}" > "${out}"

