#!/bin/bash
#SBATCH -J isoseq3_2
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 10
#SBATCH --mem=56G
#SBATCH --array=[0-3]
#SBATCH -o %x.%A.%a.out
#SBATCH -e %x.%A.%a.err

#adapted from code found here: https://gitlab.com/douglas-fir-transcriptome/de-novo-assembly-of-long-reads/tree/Isoseq3-quality-control

set -e

home=/home/FCAM/msmith
core=/core/projects/EBP/smith
topdir=${core}/genome_annotation_isoseq_data
rawread_dir=${topdir}/raw_reads
iterator=${rawread_dir}/isoseq_accessions.txt
primers=${home}/transcriptome/00_process_sequencingdata/isoseq_primers.fasta

module load isoseq3/3.1.2

accs=($(cat ${iterator}))
acc=${accs[$SLURM_ARRAY_TASK_ID]}

workdir=${topdir}/${acc}
cd ${workdir}

date
echo "[M]: Host Name: `hostname`"
echo "[M]: Welcome to Slurm task $SLURM_ARRAY_TASK_ID."
echo "[M]: We are processing the IsoSeq accession ${acc}."
echo ""
echo "[M]: Trimming poly-a tails and removing concatmers..."

isoseq3 refine ${acc}.fl.primer_5p--primer_3p.bam ${primers} ${acc}.flnc.bam --require-polya

echo ""
date
echo "[M]: Second trim step complete."
echo "[M]: Beginning clustering..."

isoseq3 cluster ${acc}.flnc.bam ${acc}.unpolished.bam --verbose

echo ""
date
echo "[M]: Clustering complete."
echo "[M]: Beginning polishing..."

isoseq3 polish ${acc}.unpolished.bam ${rawread_dir}/${acc}.bam ${acc}.polished.bam --verbose

echo ""
date
echo "[M]: Polishing, and all processing, complete."
echo "[M]: Generating summary..."

isoseq3 summarize ${acc}.polished.bam ${acc}.summary.csv --verbose;

echo ""
date
echo "[M]: Isoseq processing pipeline complete. Bye!"
