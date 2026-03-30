#!/bin/bash
#SBATCH -J mitohifi
#SBATCH -p himem
#SBATCH -q himem
#SBATCH -c 24
#SBATCH --mem=250G
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

home=/home/FCAM/msmith
core=/core/projects/EBP/smith
asm=${core}/manual_curation_files/interior_primary_final_mancur2.fa
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
