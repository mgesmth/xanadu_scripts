#!/bin/bash
#SBATCH -J minigraph_broken
#SBATCH -p himem
#SBATCH -q himem
#SBATCH -c 36
#SBATCH --mem=500G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=ALL
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

echo `hostname`

core=/core/projects/EBP/smith
home=/home/FCAM/msmith
scratch=/scratch/msmith
prim_unbroken=${core}/CBP_assemblyfiles/interior_primary_1Mb.fa
prim_broken=${scratch}/interior_primary_1Mb_broken.fa
alt_unbroken=${core}/CBP_assemblyfiles/interior_alternate_1Mb.fa
alt_broken=${scratch}/interior_alternate_1Mb_broken.fa
out=/home/FCAM/msmith/minigraph_out/primalt_brokenscaffolds
#YaHS separates contigs during scaffolding with blocks of Ns 200 long
N_threshold=200
threads="36"

##Break scaffolds with Quast
##NOTE: I had to edit break_scaffolds_into_contigs.py at line 57 - fastaparser module has function "write_fasta", not "write_fasta_to_file"
source ${home}/quast/.venv/bin/activate
unbroken_prim_name=`basename ${prim_unbroken}`
unbroken_alt_name=`basename ${alt_unbroken}`
echo "[M]: Breaking scaffolded assembly ${unbroken_prim_name} into contigs and writing to ${prim_broken}."
${home}/quast_out/quast/other_scripts/break_scaffolds_into_contigs.py "${prim_unbroken}" "$N_threshold" "${prim_broken}"
echo "[M]: Breaking scaffolded assembly ${unbroken_alt_name} into contigs and writing to ${alt_broken}."
${home}/quast_out/quast/other_scripts/break_scaffolds_into_contigs.py "${alt_unbroken}" "$N_threshold" "${alt_broken}"
deactivate

##Move onto Minigraph with broken assemblies
module load zlib/1.2.11
export PATH="${core}/bin/minigraph-0.21:$PATH"
export PATH="${core}/bin/gfatools:$PATH"

${home}/scripts/minigraph_gfatoolsbbl.sh -t "$threads" -r "${prim_broken}" -q "${alt_broken}" -o "${out}"
