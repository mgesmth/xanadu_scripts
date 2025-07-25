#!/bin/bash
#SBATCH -J juicer_finalsetup
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 8
#SBATCH --mem=20G
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=meg8130@student.ubc.ca
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

echo `hostname`

set -e

echo "[M]: Host Name: `hostname`"

home=/home/FCAM/msmith
core=/core/projects/EBP/smith
scratch=/scratch/msmith
ori_jd=${core}/juicer_formanualcur
gid="intdf137"
site="Arima"
threads=36

mv ${ori_jd} ${scratch}/
jd=${scratch}/juicer_formanualcur

echo "[M]: Beginning setup"

#SOFT-LINK FILES ---
cd ${jd}/references
ln -s ${core}/CBP_assemblyfiles/interior_primary_final.fa interior_primary_final.fa
ln -s ${core}/CBP_assemblyfiles/interior_primary_final.fa.amb interior_primary_final.fa.amb
ln -s ${core}/CBP_assemblyfiles/interior_primary_final.fa.ann interior_primary_final.fa.ann
ln -s ${core}/CBP_assemblyfiles/interior_primary_final.fa.pac interior_primary_final.fa.pac
ln -s ${core}/CBP_assemblyfiles/interior_primary_final.fa.bwt interior_primary_final.fa.bwt
ln -s ${core}/CBP_assemblyfiles/interior_primary_final.fa.sa interior_primary_final.fa.sa
cd ../work/intdf137/splits
#Move bam files into splits folder
for file in $(ls -1 ${scratch}/hic_bams/*.bam) ; do
  mv ${file} .
done
cd ../fastq
#Touch files that would have corresponded to the bam files (required from the wiki); link to these files in split
for R1 in $(cat ${scratch}/hic_split/fastqs.txt); do
  R2=$(echo "$R1" | sed 's/R1/R2/')
  touch "$R1"
  touch "$R2"
  cd ../splits
  ln -s ${jd}/work/intdf137/fastq/"$R1" "$R1"
  ln -s ${jd}/work/intdf137/fastq/"$R2" "$R2"
  cd ../fastq
done

if [[ $? -eq 0 ]] ; then
  echo "[M]: Setup complete."
  exit 0
else
  echo "[E]: Setup failed. Exiting."
  exit 1
fi
