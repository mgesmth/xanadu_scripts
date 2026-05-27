#!/bin/bash
#SBATCH -J mitohifi
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 24
#SBATCH --mem=500G
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

home=/home/FCAM/msmith
core=/core/projects/EBP/smith
scratch=/scratch/msmith
asm=${core}/final_genome/psme_glauca_primary_minorscaffolds.fasta
#just running on the minor scaffolds - was running out of memory and just going to assume no mtDNA made it into major scaffs
outdir=${home}/mitohifi/contigs
longreads_fq=/seqdata/EBP/plant/Pseudotsuga_menziesii/allhifi_merged_trimmed.fastq.gz
longreads=${scratch}/allhifi_merged_trimmed.fasta.gz

module load singularity/3.9.2 seqtk/1.3

#seqtk seq -a ${longreads_fq} | gzip -c > ${longreads}

#findMitoReference.py --species "Pseudotsuga menziesii" --outfolder ${outdir}
#Downloaded Lacebark pine mitogenome
relative="PQ593531.1"

echo "`date`:[M]: Host name: `hostname`"
echo -e "`date`:[M]: Beginning mitogenome assembly from scaffolded assembly.\n"

cd ${outdir}

singularity exec ${core}/bin/MitoHiFi.sif \
mitohifi.py -p 60 -c ${asm} -f "${relative}.fasta" -g "${relative}.gb" -t 24 -a "plant"
