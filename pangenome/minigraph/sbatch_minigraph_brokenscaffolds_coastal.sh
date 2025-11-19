#!/bin/bash
#SBATCH -J minigraph_broken
#SBATCH -p himem
#SBATCH -q himem
#SBATCH -c 36
#SBATCH --mem=200G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=meg8130@student.ubc.ca
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

echo `hostname`

core=/core/projects/EBP/smith
home=/home/FCAM/msmith
scratch=/scratch/msmith
primalt_broken=${home}/minigraph_out/primalt_brokenscaffolds.gfa
coa_unbroken=${core}/coastal/coastalDF_scaffrenamed_sorted_1Mb.fa
coa_broken=${scratch}/coastal_1Mb_broken.fa
out=/home/FCAM/msmith/minigraph_out/all_brokenscaffolds
######Coastal contigs are separated by gaps of 100 N's -- figured this out by:
######This is how I figured out how contigs were spaced in coastal asm
#grep -nb "N" coastalDF_scaffrenamed_sorted.fa | head -n10
######this outputs lines containing ns, their line names and byte offset within the file as a whole
######in the output you can see which lines are sequential based on their line numbers - i.e., strings of Ns
######Select a block of N's, with grep and then head/tail | isolate the Ns, one N per line | count the number of lines to get number of Ns
######For example:
#grep -nb "N" coastalDF_scaffrenamed_sorted.fa | head -n9 | tail -n4 | grep -o "N" | wc -l
#######Do this a few times to confirm the regularity of these blocks of Ns
########Doing this shows me that coastal contigs are separated by blocks of 100 Ns
########Did it for interior just to see and I got blocks of 200 Ns, as expected.
########YaHS spaces contigs with gaps 200 N's long.

N_threshold=100
threads="36"

##Break scaffolds with Quast
##NOTE: I had to edit break_scaffolds_into_contigs.py at line 57 - fastaparser module has function "write_fasta", not "write_fasta_to_file"
source ${home}/quast_out/.venv/bin/activate
unbroken_coa_name=`basename ${coa_unbroken}`
echo "[M]: Breaking scaffolded assembly ${unbroken_coa_name} into contigs and writing to ${coa_broken}."
${home}/quast_out/quast/other_scripts/break_scaffolds_into_contigs.py "${coa_unbroken}" "$N_threshold" "${coa_broken}"
deactivate

##Move onto Minigraph with broken assemblies
module load zlib/1.2.11
export PATH="${core}/bin/minigraph-0.21:$PATH"
export PATH="${core}/bin/gfatools:$PATH"

${home}/scripts/minigraph_gfatoolsbbl.sh -t "$threads" -r "${primalt_broken}" -q "${coa_broken}" -o "${out}"
