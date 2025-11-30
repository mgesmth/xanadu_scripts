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

cd ${jd}
rm _in.bam
rm _norm.txt.res.txt

cd work/intdf137

rm splitsallhiC*.fastq
cd ${splits}

ls -1 *.bam | sed 's/.bam//g'> bams.txt
mv bams.txt ${fastq}
cd ${fastq}
for bam in $(cat bams.txt) ; do
  r1="${bam//.fastq}_R1.fastq"
  r2="${bam//.fastq}_R2.fastq"
  touch ${r1}
  touch ${r2}
done && rm bams.txt

cd ${splits}
ln -s ../fastq/* .
