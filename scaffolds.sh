#!/bin/bash
#SBATCH --job-name=scaffold
#SBATCH --partition=himem2
#SBATCH --qos=himem2
#SBATCH --nodes=1
#SBATCH --cpus-per-task=36
#SBATCH --mem=950G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=meg.smith@ubc.ca
#SBATCH -o scaffold_%j.out
#SBATCH -e scaffold_%j.err

#script is modified from run_yahs.sh which is included in the YaHS downloadable
echo `hostname`
module load YaHS/1.2.2
module load juicer/1.8.9
module load samtools/1.20

juicer_tools_pre="java -jar /isg/shared/apps/juicer/1.8.9/scripts/juicer_tools.1.8.9_jcuda.0.8.jar pre --threads 36"
juicer_pre="/isg/shared/apps/YaHS/1.2.2/juicer pre"
home=/home/FCAM/msmith/yahs
contigs=${home}/contigs/intDF011.asm.hic.p_ctg.fasta
bam=${home}/bams/aligned_hic_sorted_markdup.bam
core=/core/projects/EBP/smith
outdir=${core}/scaffold
out="intDF011"

##run yahs scaffolding 
yahs -o ${outdir}/${out} ${contigs} ${bam} 

##input files for juicer_tools
($juicer_pre ${outdir}/${out}.bin ${outdir}/${out}_scaffolds_final.agp ${contigs}.fai 2>${outdir}/tmp_juicer_pre.log | LC_ALL=C sort -k2,2d -k6,6d -T ${outdir} --parallel=36 -S500G | awk 'NF' > ${outdir}/alignments_sorted.txt.part) && (mv ${outdir}/alignments_sorted.txt.part ${outdir}/alignments_sorted.txt)

##chromosome size file
cat ${outdir}/tmp_juicer_pre.log | grep "PRE_C_SIZE" | cut -d' ' -f2- > ${outdir}/${out}_scaffolds_final.chrom.sizes

##juicer_tools hic map
($juicer_tools_pre ${outdir}/alignments_sorted.txt ${outdir}/${out}.hic.part ${outdir}/${out}_scaffolds_final.chrom.sizes) && {mv ${outdir}/${out}.hic.part ${outdir}/${outdir}/${out}.hic)

##juicer_tools JBAT mode
$juicer_pre -a -o ${outdir}/${out}_JBAT ${outdir}/{out}.bin ${outdir}/${out}_scaffolds_final.agp ${contigs}.fai 2> ${outdir}/tmp_juicer_pre_JBAT.log
cat ${outdir}/tmp_juicer_pre_JBAT.log | grep "PRE_C_SIZE" | cut -d' ' -f2- > ${outdir}/${out}_JBAT.chrom.sizes
($juicer_tools_pre ${outdir}/${out}_JBAT.txt ${outdir}/${out}_JBAT.hic.part ${outdir}/${out}_JBAT.chrom.sizes) && (mv ${outdir}/${out}_JBAT.hic.part ${outdir}/${out}_JBAT.hic)

#next steps involve manual curation with Juicebox, which is a GUI, so gonna do that in a later step
