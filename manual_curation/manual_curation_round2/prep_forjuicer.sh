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

module load bwa/0.7.17
module load samtools/1.20
module load python/3.8.1
module load seqkit/2.10.0
home=/home/FCAM/msmith
core=/core/projects/EBP/smith
scratch=/scratch/msmith
juicedir=${core}/juicer_formanualcur
export PATH="${juicedir}/scripts:$PATH"
prim=${juicedir}/references/interior_primary_final.fa
prim_name=$(basename ${prim})
gid="intdf137"
enzyme="Arima"

R1=${home}/hiC_data/allhiC_R1.fastq.gz
R2=${home}/hiC_data/allhiC_R2.fastq.gz
hic_split=${scratch}/hic_split
hic_bams=${scratch}/hic_bams
splitN=300

if [[ ! -d "$hic_split" ]] ; then
  mkdir ${hic_split}
fi

if [[ ! -d "$hic_bams" ]] ; then
  mkdir ${hic_bams}
fi

echo -e "\n[M]: Splitting Hi-C data\n"

seqkit split2 -1 "$R1" -2 "$R2" -p "$splitN" -O "$hic_split" -f
cd $hic_split
ls *.fastq* > fastqs.txt

#Don't need to re-create site positions file, I already have it from the first run. Keeping this code here for the record.
#date=$(date)
#echo -e "\n${date}:[M]: HiC data split. Moving onto site_positions file."
  
#cd ${juicedir}/restriction_sites
#python ${juicedir}/scripts/generate_site_positions.py "$enzyme" "$gid" "$prim"

#date=$(date)
#echo -e "\n${date}:[M]: Site positions generated. Bye."

date=$(date)
echo -e "\n${date}:[M]: Complete. Bye."
