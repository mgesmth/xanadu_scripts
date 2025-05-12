#!/bin/bash
#SBATCH -J juicer_arrowhead
#SBATCH -p himem2
#SBATCH -q himem
#SBATCH -c 12
#SBATCH --mem=300G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=meg8130@student.ubc.ca
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

module load python/3.10.1
module load bwa/0.7.17
module load juicer/1.22.01

scratch=/scratch/msmith
core=/core/projects/EBP/smith
home=/home/FCAM/msmith
hic=${home}/interior_primary_contacts.hic
out=${scratch}/interior_primary_contactdomains.txt

java -Xmx250G -jar $JUICER arrowhead --threads 12 --ignore-sparsity -k KR "${hic}" "${out}"
