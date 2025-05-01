#!/bin/bash
#SBATCH -J minigraph_broken_scaff1
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 12
#SBATCH --mem=150G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=ALL
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

echo `hostname`

prim=/scratch/msmith/scaffold_1_primary_broken.fa
alt=/scratch/msmith/forscaffold_1_primary_alternate_broken.fa
out=/home/FCAM/msmith/minigraph_out/testbroken_scaffold1
threads="12"

module load zlib/1.2.11
export PATH="${core}/bin/minigraph-0.21:$PATH"
export PATH="${core}/bin/gfatools:$PATH"

${home}/scripts/minigraph_gfatoolsbbl.sh -t "$threads" -r "${prim}" -q "${alt}" -o "${out}"
