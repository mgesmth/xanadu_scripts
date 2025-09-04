#!/bin/bash
#SBATCH -J minigraph_launch
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 1
#SBATCH --mem=1G
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

set -e
date

home=/home/FCAM/msmith
core=/core/projects/EBP/smith
scratch=/scratch/msmith
prim=${scratch}/interior_primary_final_mancur_bigscaffoldsplit.fa
alt=${scratch}/interior_alternate_1Mb.fa
coast=${scratch}/coastal_1Mb.fa
prx="final_finalpangenome"
outdir=${core}/manual_curation_files/minigraph
scripts=${home}/scripts/post_asm_analysis

##Generate pangenome graph ----
sbatch ${scripts}/pangenome_graph_generation.sh > pangen.jid
pangen_jid=$(cat pangen_jid.txt | cut -d ' ' -f4)

#Call paths through all asms in pangenome (including reference) - neccesary to get the VCF files
##Call primary ----
sbatch -d afterok:${pangen_jid} ${scripts}/pangenome_callpath.sh ${prim} "${prx}_primcall" > primcall.jid
primcall_jid=$(cat primcall.jid | cut -d ' ' -f4)
##Call alternate ----
sbatch -d afterok:${pangen_jid} ${scripts}/pangenome_callpath.sh ${alt} "${prx}_altcall" > altcall.jid
altcall_jid=$(cat altcall.jid | cut -d ' ' -f4)
##Call coastal ----
sbatch -d afterok:${pangen_jid} ${scripts}/pangenome_callpath.sh ${coa} "${prx}_coastcall" > coacall.jid
coacall_jid=$(cat coacall.jid | cut -d ' ' -f4)

#Generate VCF
sbatch -d afterok:${primcall_jid},${altcall_jid},${coacall_jid} ${scripts}/pangenome_bed2vcf.sh > bed2vcf.jid
bed2vcf_jid=$(cat bed2vcf.jid | cut -d ' ' -f4)

#Categorize SVs
sbatch -d afterok:${bed2vcf_jid} ${scripts}/pangenome_categorizesvs.sh

if [[ $? -eq 0 ]] ; then
	echo "[M]: All jobs submitted."
 	rm *.jid
  	exit 0
else
	echo "[E]: Job submission failed. Exiting."
	rm *.jid
 	exit 1
fi
