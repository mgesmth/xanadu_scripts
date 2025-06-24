#!/bin/bash
#SBATCH -J minigraph
#SBATCH -p himem2
#SBATCH -q himem
#SBATCH -c 24
#SBATCH --mem=750G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=meg8130@student.ubc.ca
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

echo `hostname`

core=/core/projects/EBP/smith
home=/home/FCAM/msmith
scratch=/scratch/msmith
prim=${scratch}/interior_primary_scaffold1split.fa
alt=${scratch}/interior_alternate_1Mb.fa
coa=${scratch}/coastal_1Mb.fa
threads="24"
outfix=${home}/svs/minigraph_out/all_primscaff1split

##Break scaffolds with Quast
##NOTE: I had to edit break_scaffolds_into_contigs.py at line 57 - fastaparser module has function "write_fasta", not "write_fasta_to_file"
#source ${home}/quast_out/.venv/bin/activate
#unbroken_prim_name=`basename ${prim_unbroken}`
#unbroken_alt_name=`basename ${alt_unbroken}`
#echo "[M]: Breaking scaffolded assembly ${unbroken_prim_name} into contigs and writing to ${prim_broken}."
#${home}/quast_out/quast/other_scripts/break_scaffolds_into_contigs.py "${prim_unbroken}" "$N_threshold" "${prim_broken}"
#echo "[M]: Breaking scaffolded assembly ${unbroken_alt_name} into contigs and writing to ${alt_broken}."
#${home}/quast_out/quast/other_scripts/break_scaffolds_into_contigs.py "${alt_unbroken}" "$N_threshold" "${alt_broken}"
#deactivate

##Move onto Minigraph with broken assemblies
module load zlib/1.2.11
export PATH="${core}/bin/minigraph-0.21:$PATH"
export PATH="${core}/bin/gfatools:$PATH"

#${home}/scripts/minigraph_gfatoolsbbl.sh -t "$threads" -r "${prim}" -q "${alt}" -x "${coa}" -o "${outfix}"
minigraph -cxggs -t "$threads" "$prim" "$alt" "$coa" > "${out}.gfa"
gfatools bubble "${out}.gfa" > "${out}.bed"
