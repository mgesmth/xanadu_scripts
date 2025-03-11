#!/bin/bash
#SBATCH --job-name=scaffold
#SBATCH --partition=himem2
#SBATCH --qos=himem
#SBATCH --nodes=1
#SBATCH --cpus-per-task=36
#SBATCH --mem=1000G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=meg8130@student.ubc.ca
#SBATCH -o scaffold_%j.out
#SBATCH -e scaffold_%j.err

echo `hostname`
module load samtools/1.20
module load bwa/0.7.17
module load picard/2.23.9
module load purge_dups/1.2.6

scratch=/scratch/msmith
home=/home/FCAM/msmith
core=/core/projects/EBP/smith
hic=${home}/hiC_data
bwa_outdir=${home}/yahs/bams
contigs=${home}/yahs/contigs/intDF011.asm.hic.p_ctg_purged.fa
juicer_tools_pre="java -jar /isg/shared/apps/juicer/1.8.9/scripts/juicer_tools.1.8.9_jcuda.0.8.jar pre --threads 36"
juicer_pre="/isg/shared/apps/YaHS/1.2.2/juicer pre"
pd_scripts=/isg/shared/apps/purge_dups/1.2.6/scripts
pd_bin=/isg/shared/apps/purge_dups/1.2.6/bin
bam=${home}/yahs/bams/aligned_hic_sorted_markdup.bam
outdir=${core}/scaffold
out="intDF011"

##Purge_dups ----

${pd_scripts}/run_purge_dups.py -p bash ${home}/yahs/contigs/intDF011_config.json ${pd_bin} intDF011
mv ${scratch}/seqs/intDF011.asm.hic.p_ctg_purged.fa ${home}/yahs/contigs

contigs=${home}/yahs/contigs/intDF011.asm.hic.p_ctg_purged.fa
#align reads and convert SAM to BAM
bwa index $contigs
samtools faidx $contigs
bwa mem $contigs $hic/allhiC_R1.fastq.gz $hic/allhiC_R2.fastq.gz \
-SP5M -t 36 -R '@RG\tID:1\tSM:482stagleap\tPL:illumina'| \
samtools view -bh -q 10 -o aligned_hic_unsorted.bam
samtools sort -n -@ 36 -T ${scratch} -o ${scratch}/aligned_hic_sorted.bam
if [ $? -eq 0 ] ; then
rm ${scratch}/aligned_hic_unsorted.bam
mv ${scratch}/aligned_hic_sorted.bam ${bwa_outdir}/
else
exit 1
fi

#bwa mem parameters -SP skips a step that would force alignment of poorly aligned read given 
#alignment of its mate, -5 reports 5' portion of chimeric alignments as the primary alignment
#useful in the context of hi-C library prep (5' is usually position of interest)
#-M annotate secondary clipped reads as secondary rather than supplementary, useful for markdups?

#mark duplicates - also recommended by yahs
java -Xmx800G -jar $PICARD MarkDuplicates \
-I ${bwa_outdir}/aligned_hic_sorted.bam -O ${outdir}/aligned_hic_sorted_dedup.bam -M ${outdir}/markdups_metrics.txt \
--TMP_DIR ${scratch} --REMOVE_DUPLICATES true --ASSUME_SORT_ORDER queryname

############ -----

module load YaHS/1.2.2
module load juicer/1.8.9

#script is modified from run_yahs.sh which is included in the YaHS downloadable

##run yahs scaffolding 
yahs -o ${outdir}/${out} ${contigs} ${bam} 

if [ $? -eq 0 ] ; then
echo 'Yahs success'
elif [ $? -eq 1 ] ; then
echo 'error 1: Yahs'
else
echo 'error non-1: Yahs'
fi

#agp_to_fasta
agp_to_fasta ${outdir}/${out}_scaffolds_final.agp ${contigs} -o ${outdir}/${out}.fasta

if [ $? -eq 0 ] ; then
echo 'agp_to_fasta success'
elif [ $? -eq 1 ] ; then
echo 'error 1: agp_to_fasta'
else
echo 'error non-1: agp_to_fasta'
fi

##input files for juicer_tools
($juicer_pre ${outdir}/${out}.bin ${outdir}/${out}_scaffolds_final.agp ${contigs}.fai 2>${outdir}/tmp_juicer_pre.log | LC_ALL=C sort -k2,2d -k6,6d -T ${outdir} --parallel=36 -S500G | awk 'NF' > ${outdir}/alignments_sorted.txt.part) && (mv ${outdir}/alignments_sorted.txt.part ${outdir}/alignments_sorted.txt)

if [ $? -eq 0 ] ; then
echo 'juicer pre success'
elif [ $? -eq 1 ] ; then
echo 'error 1: juicer pre'
else
echo 'error non-1: juicer pre'
fi

##chromosome size file
cat ${outdir}/tmp_juicer_pre.log | grep "PRE_C_SIZE" | cut -d' ' -f2- > ${outdir}/${out}_scaffolds_final.chrom.sizes

if [ $? -eq 0 ] ; then
echo 'chrom size file success'
elif [ $? -eq 1 ] ; then
echo 'error 1: chrom size file'
else
echo 'error non-1: chrom size file'
fi

##juicer_tools hic map
($juicer_tools_pre ${outdir}/alignments_sorted.txt ${outdir}/${out}.hic.part ${outdir}/${out}_scaffolds_final.chrom.sizes) && {mv ${outdir}/${out}.hic.part ${outdir}/${out}.hic)

if [ $? -eq 0 ] ; then
echo 'juicer_tools success'
elif [ $? -eq 1 ] ; then
echo 'error 1: juicer_tools'
else
echo 'error non-1: juicer_tools'
fi

##juicer_tools JBAT mode
$juicer_pre -a -o ${outdir}/${out}_JBAT ${outdir}/${out}.bin ${outdir}/${out}_scaffolds_final.agp ${contigs}.fai 2> ${outdir}/tmp_juicer_pre_JBAT.log
cat ${outdir}/tmp_juicer_pre_JBAT.log | grep "PRE_C_SIZE" | cut -d' ' -f2- > ${outdir}/${out}_JBAT.chrom.sizes
($juicer_tools_pre ${outdir}/${out}_JBAT.txt ${outdir}/${out}_JBAT.hic.part ${outdir}/${out}_JBAT.chrom.sizes) && (mv ${outdir}/${out}_JBAT.hic.part ${outdir}/${out}_JBAT.hic)

if [ $? -eq 0 ] ; then
echo 'JBAT mode success'
elif [ $? -eq 1 ] ; then
echo 'error 1: JBAT mode'
else
echo 'error non-1: JBAT mode'
fi

#next steps involve manual curation with Juicebox, which is a GUI, so gonna do that in a later step
