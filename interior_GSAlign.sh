#!/bin/bash
#SBATCH --job-name=gsalign
#SBATCH -p himem
#SBATCH -q himem
#SBATCH -c 24
#SBATCH --mem=500G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=meg8130@student.ubc.ca
#SBATCH -o gsalign_interior.%j.out
#SBATCH -e gsalign_interior.%j.err

core=/core/projects/EBP/smith
primary=${core}/CBP_assemblyfiles/interior_primary_1Mb.fa
alternate=${core}/CBP_assemblyfiles/interior_alternate_1Mb.fa
output=/home/FCAM/msmith/GSAlign/interior_gsalign

export PATH="${core}/bin/GSAlign/bin:$PATH"
export PATH="/home/FCAM/msmith/scripts:$PATH"

gsalign.sh -t 24 -r ${primary} -q ${alternate} -o ${output}
