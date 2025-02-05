#!/bin/bash
#SBATCH --job-name=blast
#SBATCH --partition=himem
#SBATCH --qos=himem
#SBATCH --cpus-per-task=10
#SBATCH --mem=200G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=meg8130@student.ubc.ca
#SBATCH -o blast.%j.out
#SBATCH -e blast.%e.err

module load blast/2.7.1

home=/home/FCAM/msmith
scratch=/scratch/msmith
hifi=${home}/hifi_data
blastdir=/core/project/EBP/smith/blast
vectors=${blastdir}/DB/pacbio_vectors_db

zcat $hifi | sed -n '1~4s/^@/>/p;2~4p' > ${scratch}/allhifi.fasta
blastn -db $vectors -query ${scratch}/allhifi.fasta -num_threads 12 -task blastn \
-reward 1 -penalty -5 -gapopen 3 -gapextend 3 -dust no -soft_masking true \
-evalue 700 -searchsp 1750000000000 -outfmt 6 > ${blastdir}/allhifi.contaminant.blastout
