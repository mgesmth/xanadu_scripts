#!/bin/bash
#SBATCH --job-name=pairscaff
#SBATCH --partition=himem2
#SBATCH --qos=himem
#SBATCH --cpus-per-task=36
#SBATCH --mem=1000G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=meg8130@student.ubc.ca
#SBATCH -o pairscaff_hap1.%j.out
#SBATCH -e pairscaff_hap1.%j.err

echo `hostname`

module load samtools/1.20
module load bwa/0.7.17
module load pairtools/0.2.2
module load YaHS/1.2.2
module load quast/5.2.0

home=/home/FCAM/msmith
core=/core/projects/EBP/smith
scratch=/scratch/msmith
INDEX=${home}/yahs/contigs/intDF011.asm.hic.hap1.p_ctg.fasta
CHROM_SIZES=${home}/yahs/contigs/intDF011.asm.hic.hap1.p_ctg.chrom.sizes
FASTQ1=${home}/hiC_data/allhiC_R1.fastq.gz
FASTQ2=${home}/hiC_data/allhiC_R2.fastq.gz
IN_BAM=${scratch}/aligned_hic_hap1.bam
OUTPREFIX=${scratch}/intDF011_hap1
NODUPS_SAM_PATH=${OUTPREFIX}.nodups.bam
NODUPS_PAIRS_PATH=${OUTPREFIX}.nodups.pairs

bwa index ${INDEX}
bwa mem -SP5 -t 36 "${INDEX}" "${FASTQ1}" "${FASTQ2}" | samtools view -bh -o "${IN_BAM}"

pairtools parse --chroms-path "${CHROM_SIZES}" "${IN_BAM}"
} | {
pairtools sort --nproc 24 --memory 350G --tmpdir ${scratch}
} | {
pairtools dedup
} | {
pairtools split --output-pairs ${NODUPS_PAIRS_PATH} --output-sam ${NODUPS_SAM_PATH}
}

out="intDF011_hap1"
outdir=${core}/scaffold/withpairtools_noec_hap1
bam="${NODUPS_SAM_PATH}"
juicer_tools_pre="java -jar /isg/shared/apps/juicer/1.8.9/scripts/juicer_tools.1.8.9_jcuda.0.8.jar pre --threads 36"
juicer_pre="/isg/shared/apps/YaHS/1.2.2/juicer pre"
quast_out=${home}/quast_out/1_3_hap1

yahs --no-contig-ec -l 10 -e GATC,GANTC -o ${outdir}/${out} ${INDEX} ${bam}

quast.py -t 12 --split-scaffolds --large -o $quast_out ${outdir}/intDF011_hap1_scaffolds_final.fa

##input files for juicer_tools
#$juicer_pre ${outdir}/${out}.bin ${outdir}/${out}_scaffolds_final.agp ${contigs}.fai \
#2>${outdir}/tmp_juicer_pre.log | LC_ALL=C sort -k2,2d -k6,6d -T ${outdir} --parallel=36 \
#-S500G | awk 'NF' > ${outdir}/alignments_sorted.txt.part \
#&& mv ${outdir}/alignments_sorted.txt.part ${outdir}/alignments_sorted.txt

#cat ${outdir}/tmp_juicer_pre.log | grep "PRE_C_SIZE" | cut -d' ' -f2- > \
#${outdir}/${out}_scaffolds_final.chrom.sizes

#$juicer_tools_pre ${outdir}/alignments_sorted.txt ${outdir}/${out}.hic.part ${outdir}/${out}_scaffolds_final.chrom.sizes \
#&& mv ${outdir}/${out}.hic.part ${outdir}/${out}.hic

#JBAT Mode
#$juicer_pre -a -o ${outdir}/${out}_JBAT ${outdir}/${out}.bin ${outdir}/${out}_scaffolds_final.agp ${contigs}.fai 2> ${outdir}/tmp_juicer_pre_JBAT.log

#cat ${outdir}/tmp_juicer_pre_JBAT.log | grep "PRE_C_SIZE" | cut -d' ' -f2- > ${outdir}/${out}_JBAT.chrom.sizes

#$juicer_tools_pre ${outdir}/${out}_JBAT.txt ${outdir}/${out}_JBAT.hic.part ${outdir}/${out}_JBAT.chrom.sizes && mv ${outdir}/${out}_JBAT.hic.part ${outdir}/${out}_JBAT.hic
