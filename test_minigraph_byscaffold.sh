#!/bin/bash
#SBATCH --job-name=test_minigraph_byscaff
#SBATCH --partition=himem
#SBATCH --qos=himem
#SBATCH --cpus-per-task=24
#SBATCH --mem=350G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=meg8130@student.ubc.ca
#SBATCH -e test_minigraph_byscaffold.out
#SBATCH -o test_minigraph_byscaffold.err

echo `hostname`
home=/home/FCAM/msmith
scratch=/scratch/msmith
core=/core/projects/EBP/smith
reference=${core}/CBP_assemblyfiles/interior_primary_1Mb.fa
scaffold=${core}/CBP_assemblyfiles/interior_alternate_scaffold1.fa
out_gfa=${scratch}/int_scaffold1.gfa
out_bubble=${home}/minigraph_out/int_scaffold1_bubble.bed
out_call=${home}/minigraph_out/int_scaffold1_call.bed

module load zlib/1.2.11
export PATH="${core}/bin/minigraph:$PATH"
export PATH="${core}/bin/gfatools:$PATH"

minigraph -cxggs -t 24 ${reference} ${scaffold} > ${out_gfa}
gfatools bubble ${out_gfa} > ${out_bubble}
minigraph -cxasm -t 24 ${reference} ${scaffold} > ${out_call}  
