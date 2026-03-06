#!/bin/bash
#SBATCH -J prep_forjuicer
#SBATCH -p himem
#SBATCH -q himem
#SBATCH -c 24
#SBATCH --mem=128G
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

set -e

date
echo "[M]: Host Name: `host name`"

module load bwa/0.7.17 samtools/1.20 python/3.8.1 seqkit/2.10.0
home=/home/FCAM/msmith
core=/core/projects/EBP/smith
scratch=/scratch/msmith
juicedir=${core}/juicer_alt
export PATH="${juicedir}/scripts:$PATH"
alt=${juicedir}/references/interior_alternate_final.fa
alt_name=$(basename ${alt})
gid="intdf137_alt"
enzyme="Arima"

R1=${home}/hiC_data/allhiC_R1.fastq.gz
R2=${home}/hiC_data/allhiC_R2.fastq.gz
hic_split=${juicedir}/work/intdf_137/fastq
hic_bams=${juicedir}/work/intdf_137/splits
splitN=300

echo -e "\n[M]: Splitting Hi-C data\n"

seqkit split2 -1 "$R1" -2 "$R2" -p "$splitN" -O "$hic_split" -f
cd $hic_split
ls allhiC_R1*.fastq.gz > fastqs.txt

date=$(date)
echo -e "\n${date}:[M]: HiC data split. Moving onto site_positions file."

cd ${juicedir}/restriction_sites
python ${juicedir}/scripts/generate_site_positions.py "$enzyme" "$gid" "$alt"

date=$(date)
echo -e "\n${date}:[M]: Site positions generated. Creating BWA index."

cd ${juicedir}/references
bwa index ${alt}

date=$(date)
echo -e "\n${date}:[M]: Complete. Bye."
