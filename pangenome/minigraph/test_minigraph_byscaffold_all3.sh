#!/bin/bash
#SBATCH --job-name=test_minigraph_byscaff
#SBATCH --partition=himem
#SBATCH --qos=himem
#SBATCH --cpus-per-task=24
#SBATCH --mem=350G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=meg8130@student.ubc.ca
#SBATCH -o test_minigraph_byscaffoldall.%j.out
#SBATCH -e test_minigraph_byscaffoldall.%j.err

echo `hostname`
home=/home/FCAM/msmith
scratch=/scratch/msmith
core=/core/projects/EBP/smith
reference=${core}/CBP_assemblyfiles/interior_primary_1Mb.fa
alt=${core}/CBP_assemblyfiles/interior_alternate_scaffold1.fa
coa=${core}/coastal/coastalDF_scaffrenamed_sorted_scaff1.fa
out_call=${home}/minigraph_out/all_scaffold1_call.bed

module load zlib/1.2.11
export PATH="${core}/bin/minigraph-0.21:$PATH"
export PATH="${core}/bin/gfatools-0.5:$PATH"

minigraph -cxasm -t 24 ${reference} ${alt} ${coa} > ${out_call}  
