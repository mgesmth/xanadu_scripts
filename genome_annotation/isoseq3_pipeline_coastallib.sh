#!/bin/bash
#SBATCH -J isoseq3_2
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 18
#SBATCH --mem=82G
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

#adapted from code found here: https://gitlab.com/douglas-fir-transcriptome/de-novo-assembly-of-long-reads/tree/Isoseq3-quality-control

set -e

home=/home/FCAM/msmith
core=/core/projects/EBP/smith
topdir=${core}/genome_annotation_isoseq_data
rawread_dir=${topdir}/raw_reads
iterator=${rawread_dir}/iterator.txt
primers=${home}/transcriptome/00_process_sequencingdata/isoseq_primers.fasta

module load isoseq3/3.1.2

#the one coastal file
acc=m54083_190518_125313

workdir=${topdir}/${acc}
if [[ ! -d ${workdir} ]] ; then
  mkdir ${workdir}
fi
cd ${workdir}

date
echo "[M]: Host Name: `hostname`"
echo "[M]: We are processing the IsoSeq accession ${acc}."
echo "[M]: Calling consensus sequences..."
echo ""

ccs ${rawread_dir}/${acc}.subreads.bam ${acc}.ccs.bam --noPolish --minPasses 1

echo ""
date
echo "[M]: Consensus sequences called."
echo "[M]: Beginning adapter removal..."
echo ""

lima ${acc}.ccs.bam ${primers} ${acc}.fl.bam --isoseq --no-pbi --dump-clips

echo ""
date
echo "[M]: Adapters successfully trimmed."
echo "[M]: Trimming poly-a tails and removing concatmers..."
echo ""

isoseq3 refine ${acc}.fl.primer_5p--primer_3p.bam ${primers} ${acc}.flnc.bam --require-polya

echo ""
date
echo "[M]: Second trim step complete."
echo "[M]: Beginning clustering..."
echo ""

isoseq3 cluster ${acc}.flnc.bam ${acc}.unpolished.bam --verbose

echo ""
date
echo "[M]: Clustering complete."
echo "[M]: Beginning polishing..."
echo""

isoseq3 polish ${acc}.unpolished.bam ${rawread_dir}/${acc}.subreads.bam ${acc}.polished.bam --verbose

echo ""
date
echo "[M]: Polishing, and all processing, complete."
echo "[M]: Generating summary..."

isoseq3 summarize ${acc}.polished.bam ${acc}.summary.csv --verbose

echo ""
date
echo "[M]: Isoseq processing pipeline complete. Bye!"
