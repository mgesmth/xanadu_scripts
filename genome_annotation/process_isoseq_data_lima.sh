#!/bin/bash
#SBATCH -J isoseq3_1
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 10
#SBATCH --mem=56G
#SBATCH --array=[0-1]
#SBATCH -o %x.%A.%a.out
#SBATCH -e %x.%A.%a.err

#adapted from code found here: https://gitlab.com/douglas-fir-transcriptome/de-novo-assembly-of-long-reads/tree/Isoseq3-quality-control

set -e

home=/home/FCAM/msmith
core=/core/projects/EBP/smith
topdir=${core}/genome_annotation_isoseq_data
ccsread_dir=${topdir}/ccs
iterator=${ccsread_dir}/iterator.txt
primers=${home}/transcriptome/00_process_sequencingdata/isoseq_primers.fasta

module load isoseq3/3.1.2

accs=($(cat ${iterator}))
acc=${accs[$SLURM_ARRAY_TASK_ID]}

workdir=${topdir}/${acc}
if [[ ! -d ${workdir} ]] ; then
  mkdir ${workdir}
fi

cd ${workdir}

date
echo "[M]: Host Name: `hostname`"
echo "[M]: Welcome to Slurm task $SLURM_ARRAY_TASK_ID."
echo "[M]: We are processing the IsoSeq accession ${acc}."
echo ""
echo "[M]: Beginning adapter removal..."

lima ${acc}.ccs.bam ${primers} ${acc}.fl.bam --isoseq --no-pbi --dump-clips

echo ""
date
echo "[M]: Adapters successfully trimmed. Bye!"
