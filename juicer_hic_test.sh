#!/bin/bash
#SBATCH --job-name=juicer
#SBATCH --partition=general
#SBATCH --qos=general
#SBATCH --cpus-per-task=4
#SBATCH --mem=64G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=meg8130@student.ubc.ca
#SBATCH -o juicer.%j.out
#SBATCH -e juicer.%j.err

echo `hostname`

#Define variables ---
juicedir=/scratch/msmith/juicetest
juicescripts=${juicetest}/scripts
reference=${juicedir}/references/Homo_sapiens_assembly19.fasta
site="Arima"
genomeid="test"
threads="4"

#Executables ----
module load bwa/0.7.17
module load python/3.8.1
module load juicer/1.8.9
export PATH="/home/FCAM/msmith/scripts:$PATH"

test_contact_maps.sh \
    -d ${juicedir} \
    -s ${site} \
    -g ${genomeid} \
    -z ${reference} \
    -D ${juicescripts} \
    -t ${threads}
