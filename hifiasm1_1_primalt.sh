#!/bin/bash
#SBATCH --job-name=hifiasm1_1_primalt
#SBATCH --nodes=1
#SBATCH --cpus-per-task=36
#SBATCH --partition=himem2
#SBATCH --qos=himem
#SBATCH --mail-type=ALL
#SBATCH --mem=800G
#SBATCH --mail-user=meg8130@student.ubc.ca
#SBATCH -o hifiasm1_1_primalt.%j.out
#SBATCH -e hifiasm1_1_primalt.%j.err

echo `hostname`

hifidir=/home/FCAM/msmith/hifi_data #symlink to /seqdata
hiCdir=/home/FCAM/msmith/hiC_data
outdir=/core/projects/EBP/smith/hifiasm_out/hifiasm1_1_primalt

#bin files are symlinked as well - they are in the /Wegrzyn directory. hifiasm should just find them.
cd $outdir

module load Hifiasm/0.20.0

hifiasm -o ${outdir}/intDF011.asm -t 36 \
--h1 ${hiCdir}/allhiC_R1.fastq.gz --h2 ${hiCdir}/allhiC_R2.fastq.gz \
-f 39 \
${hifidir}/intDF_allhifi.fastq.gz
