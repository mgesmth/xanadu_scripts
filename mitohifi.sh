#!/bin/bash
#SBATCH -J mitohifi
#SBATCH -p himem
#SBATCH -q himem
#SBATCH -c 36
#SBATCH --mem=500G
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

home=/home/FCAM/msmith
core=/core/projects/EBP/smith
asm=${core}/manual_curation_files/minor_scaffolds.fa
#just running on the minor scaffolds - was running out of memory and just going to assume no mtDNA made it into major scaffs
outdir=${home}/mitohifi/contigs

module load singularity/3.9.2

#findMitoReference.py --species "Pseudotsuga menziesii" --outfolder ${outdir}
#Downloaded Lacebark pine mitogenome
relative="PQ593531.1"

echo "`date`:[M]: Host name: `hostname`"
echo -e "`date`:[M]: Beginning mitogenome assembly from scaffolded assembly.\n"

cd ${outdir}

singularity exec ${core}/bin/MitoHiFi.sif \
mitohifi.py -c ${asm} -f "${relative}.fasta" -g "${relative}.gb" -t 24 -a "plant"
