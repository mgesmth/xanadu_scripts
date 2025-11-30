#!/bin/bash
#SBATCH -J run_juicer_chimeric
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 6
#SBATCH -n 1
#SBATCH --mem=30G
#SBATCH --array=[0-299]
#SBATCH -o %x.%A.%a.out
#SBATCH -e %x.%A.%a.err

set -e

echo "`date`:[M]: Host Name: `hostname`"

module load samtools/1.19
module load bwa/0.7.17
module load java-sdk/1.8.0_92

home=/home/FCAM/msmith
core=/core/projects/EBP/smith
scratch=/scratch/msmith
sandbox=/sandbox/msmith
gid="intdf137"
site="Arima"
threads=6
jd=${sandbox}/juicer_formanualcur

export SLURM_ARRAY_TASK_ID=$SLURM_ARRAY_TASK_ID

echo "`date`:[M]: Beginning juicer chimeric task $SLURM_ARRAY_TASK_ID."
cd ${jd}
#Okay - now run juicer (CPU version, modified for better handling of large files)
${jd}/scripts/juicer_justchimeric.sh -f --assembly -g "$gid" -d "${jd}/work/intdf137" -s "$site" -S chimeric \
-p references/intdf137.chrom.sizes -y restriction_sites/intdf137_Arima.txt \
-z references/interior_primary_final.fa -D "$jd" -t "$threads"

echo -e "`date`:[M]: Juicer chimeric processing task $SLURM_ARRAY_TASK_ID complete."
