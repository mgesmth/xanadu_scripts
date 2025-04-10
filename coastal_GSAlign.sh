#!/bin/bash
#SBATCH --job-name=gsalign
#SBATCH -p himem
#SBATCH -q himem
#SBATCH -c 24
#SBATCH --mem=500G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=meg8130@student.ubc.ca
#SBATCH -o gsalign_coastal.%j.out
#SBATCH -e gsalign_coastal.%j.err

core=/core/projects/EBP/smith
primary=${core}/CBP_assemblyfiles/interior_primary_1Mb.fa
coastal=${core}/coastal/coastalDF_scaffrenamed_sorted_1Mb.fa
output=/home/FCAM/msmith/GSAlign/coastal_gsalign

export PATH="${core}/bin/GSAlign/bin:$PATH"
export PATH="/home/FCAM/msmith/scripts:$PATH"

gsalign.sh -t 24 -r ${primary} -q ${coastal} -o ${output}
cut -d " " -f1-6 "${output}.maf" > "${output}_noseq.maf"
