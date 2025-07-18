#!/bin/bash
#SBATCH -J run_juicer
#SBATCH -p himem2
#SBATCH -q himem
#SBATCH -c 36
#SBATCH --mem=1000G
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=meg8130@student.ubc.ca
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

echo "[M]: Host Name: `hostname`"

home=/home/FCAM/msmith
core=/core/projects/EBP/smith
scratch=/scratch/msmith
ori_jd=${core}/juicer_formanualcur

mv ${ori_jd} ${scratch}/
jd=${scratch}/juicer_formanualcur

#SOFT-LINK FILES ---
cd ${jd}/references
ln -s ${core}/CBP_assemblyfiles/interior_primary_final.fa interior_primary_final.fa
ln -s ${core}/CBP_assemblyfiles/interior_primary_final.fa.amb interior_primary_final.fa.amb
ln -s ${core}/CBP_assemblyfiles/interior_primary_final.fa.ann interior_primary_final.fa.ann
ln -s ${core}/CBP_assemblyfiles/interior_primary_final.fa.pac interior_primary_final.fa.pac
ln -s ${core}/CBP_assemblyfiles/interior_primary_final.fa.bwt interior_primary_final.fa.bwt
ln -s ${core}/CBP_assemblyfiles/interior_primary_final.fa.sa interior_primary_final.fa.sa
cd ../work/intdf137/fastq



