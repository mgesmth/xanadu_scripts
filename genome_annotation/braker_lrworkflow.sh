#!/bin/bash
#SBATCH -J braker_lr
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 36
#SBATCH --mem=500G
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

set -e
date
echo "[M]: Host Name: `hostname`"

home=/home/FCAM/msmith
core=/core/projects/EBP/smith
scratch=/scratch/msmith
genome=${core}/manual_curation_files/interior_primary_mancur_masked_500kb.fa
pe_bam=${core}/genome_annotation_shortread_data/alignments/paired_end_merged.bam
se_bam=${core}/genome_annotation_shortread_data/alignments/single_end_merged.bam
prot_db=${home}/transcriptome/02_braker_annotation/conifer_geneSet_protein_v2_150.faa
lr_fastq=${core}/projects/EBP/smith/genome_annotation_longread_data/all_isoseq.fastq.gz


export PATH="${core}/bin/BRAKER/scripts:$PATH"
export PATH="${core}/bin/TSEBRA/bin:$PATH"
module load GeneMarkS-T/5.1 GeneMark-ET/4.72 minimap2/2.28 python/3.10.1 biopython/1.70 perl/5.36.0 bamtools/2.5.1 blast/2.13.0 genomethreader/1.7.3 augustus/3.6.0 prothint/2.6.0 diamond/2.1.8 cDNA_Cupcake/12.4.0
export AUGUSTUS_CONFIG_PATH="${home}/transcriptome/02_braker_annotation/config"
export BAMTOOLS_PATH=/isg/shared/apps/bamtools/2.5.1/bin/
export PROTHINT_PATH=/isg/shared/apps/ProtHint/2.6.0/bin
export DIAMOND_PATH=/isg/shared/apps/diamond/2.1.8

threads=36
wdir=${core}/braker_workingdir

#1: using braker1 protocol, train predictions using short-read RNA
braker.pl --species=int_Doug_fir --softmasking --cpu=$threads \
--genome=${genome} --bam=${pe_bam},${se_bam} --workingdir=$wdir/braker1/ 2> $wdir/braker1.log

#2: using braker2 protocol, train predictions with protein database
braker.pl --species=int_Doug_fir --genome=${genome} --softmasking --cpu=$threads --epmode --prot_seq=${prot_db} --workingdir=$wdir/braker2/ 2> $wdir/braker2.log

#3: Get gene predictions from longreads
mkdir $wdir/long_read_protocol
cd $wdir/long_read_protocol

##3.1: aln transcripts to genome
minimap2 -t $threads -ax splice:hq ${genome} ${lr_fastq} | \
samtools view -bh -o isoseq_aln.bam

##3.2: sort and decompress alignment
samtools view -h isoseq_aln.bam | sort -k 3,3 -k 4,4n > ${scratch}/isoseq_aln.s.sam
collapse_isoforms_by_sam.py --input ${lr_fastq} --fq -s ${scratch}/isoseq_aln.s.sam --dun-merge-5-shorter -o cupcake && rm ${scratch}/isoseq_aln.s.sam

##3.3: use GeneMark to predict protein sequences in the transcripts and create gene set:
stringtie2fa.py -g ${genome} -f cupcake.collapsed.gff -o cupcake.fa
gmst.pl --strand direct cupcake.fa.mrna --output gmst.out --format GFF
gmst2globalCoords.py -t cupcake.collapsed.gff -p gmst.out -o gmst.global.gtf -g ${genome}

#4: Use TSEBRA to combine all extrinsic evidence
mkdir $wdir/tsebra
cd $wdir/tsebra

tsebra.py -g ${wdir}/braker1/augustus.hints.gtf,${wdir}/braker2/augustus.hints.gtf -e $wdir/braker1/hintsfile.gff,$wdir/braker2/hintsfile.gff -l $wdir/long_read_protocol/gmst.global.gtf -c ${core}/bin/TSEBRA/config/long_reads.cfg -o tsebra.gtf
