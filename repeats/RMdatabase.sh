#!/bin/bash
#SBATCH -J RMDB
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 4
#SBATCH --mem=30G
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

echo `hostname`

module load RepeatModeler/2.0.4 RECON/1.08 RepeatScout/1.0.5 RepeatMasker/4.1.5 rmblast/2.10.0  
module load TRF/4.09 genometools/1.6.2 ucsc_genome/2012.05.22 mafft/7.471 cdhit/4.8.1 ninja/0.95

prim=/core/projects/EBP/smith/CBP_assemblyfiles/interior_primary_final.fa

BuildDatabase -name primary "$prim"
