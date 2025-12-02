#!/bin/bash
#SBATCH -J prepare_for_chimeric
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 4
#SBATCH --mem=6G
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

set -e

core=/core/projects/EBP/smith
sandbox=/sandbox/msmith
jd=${sandbox}/juicer_formanualcur
splits=${jd}/work/intdf137/splits
fastq=${jd}/work/intdf137/fastq

cd ${fastq}
rm *.fastq
for r1 in $(cat /scratch/msmith/hic_split/fastqs.txt) ; do
  r2=$(echo "$r1" | sed 's/R1/R2/')
  touch ${r1}
  touch ${r2}
done

cd ${splits}
for link in $(ls *.fastq) ; do
  unlink ${link}
done
ln -s ../fastq/* .
