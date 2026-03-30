#!/bin/bash
#SBATCH -J mitohifi
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 4
#SBATCH --mem=8G
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

home=/home/FCAM/msmith
core=/core/projects/EBP/smith
asm=${home}/dummy.fasta
outdir=${home}/mitohifi/reads

module load MitoHiFi/3.2.1 python/3.8.1

#findMitoReference.py --species "Pseudotsuga menziesii" --outfolder ${outdir}
#Downloaded Lacebark pine mitogenome
relative="PQ593531.1"

echo "`date`:[M]: Host name: `hostname`"
echo -e "`date`:[M]: Beginning mitogenome assembly from scaffolded assembly.\n"

cd ${outdir}

mitohifi.py -c ${asm} -f "${relative}.fasta" -g "${relative}.gbk" -t 4 -a "plant"
