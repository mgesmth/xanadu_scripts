#!/bin/bash
#SBATCH --job-name=pairscaff
#SBATCH --partition=himem2
#SBATCH --qos=himem
#SBATCH --cpus-per-task=36
#SBATCH --mem=1000G
#SBATCH --nodes=1
#SBATCH --mail-type=ALL
#SBATCH --mail-user=meg8130@student.ubc.ca
#SBATCH -o pairscaff.%j.out
#SBATCH -e pairscaff.%j.err

echo `hostname`

#this code is modified from example_pipeline.sh in the pairtools github
#I took out the part with bwa mem, as I've already done that

set -o errexit
set -o nounset
set -o pipefail
#these essential ensure the pipeline exits if any error is thrown

##MY VARIABLES >>>>
module load pairtools/0.2.2
module load samtools/1.20
home=/home/FCAM/msmith
core=/core/projects/EBP/smith
scratch=/scratch/msmith
##<<<<

CHROM_SIZES=${home}/yahs/contigs/intDF011_final.chrom.sizes
BAM=${home}/yahs/bams/aligned_hic_sorted.bam
OUTPREFIX=${scratch}/pairtools/intDF011

N_THREADS=36

UNMAPPED_SAM_PATH=${OUTPREFIX}.unmapped.bam
UNMAPPED_PAIRS_PATH=${OUTPREFIX}.unmapped.pairs
NODUPS_SAM_PATH=${OUTPREFIX}.nodups.bam
NODUPS_PAIRS_PATH=${OUTPREFIX}.nodups.pairs
DUPS_SAM_PATH=${OUTPREFIX}.dups.bam
DUPS_PAIRS_PATH=${OUTPREFIX}.dups.pairs

# Classify Hi-C molecules as unmapped/single-sided/multimapped/chimeric/etc
    # and output one line per read, containing the following, separated by \\v:
    #  * triu-flipped pairs
    #  * read id
    #  * type of a Hi-C molecule
    #  * corresponding sam entries
pairtools parse --chroms-path "${CHROM_SIZES}" "${BAM}" | {
    # Block-sort pairs together with SAM entries
    pairtools sort --nproc 12 --memory 200G --tmpdir ${scratch}
} | {
    # Remove duplicates, separate mapped and unmapped reads
    pairtools dedup \
        --output \
            >( pairtools split \
                --output-pairs ${NODUPS_PAIRS_PATH} \
                --output-sam ${NODUPS_SAM_PATH} ) \
        --output-dups \
            >( pairtools markasdup \
                | pairtools split \
                    --output-pairs ${DUPS_PAIRS_PATH} \
                    --output-sam ${DUPS_SAM_PATH} ) \
        --output-unmapped >( pairtools split \
            --output-pairs ${UNMAPPED_PAIRS_PATH} \
            --output-sam ${UNMAPPED_SAM_PATH} )   

}

mv ${NODUPS_SAM_PATH} ${core}/scaffold/

####---------

module load YaHS/1.2.2
module load juicer/1.8.9

bwa_outdir=${home}/yahs/bams
contigs=${home}/yahs/contigs/intDF011.asm.hic.p_ctg.fasta
juicer_tools_pre="java -jar /isg/shared/apps/juicer/1.8.9/scripts/juicer_tools.1.8.9_jcuda.0.8.jar pre --threads 36"
juicer_pre="/isg/shared/apps/YaHS/1.2.2/juicer pre"
outdir=${core}/scaffold
bam=${outdir}/intDF011.nodups.bam
out="intDF011"

#script is modified from run_yahs.sh which is included in the YaHS downloadable

##run yahs scaffolding
yahs -o ${outdir}/${out} ${contigs} ${bam}

#agp_to_fasta
agp_to_fasta ${outdir}/${out}_scaffolds_final.agp ${contigs} -o ${outdir}/${out}.fasta

##input files for juicer_tools
$juicer_pre ${outdir}/${out}.bin ${outdir}/${out}_scaffolds_final.agp ${contigs}.fai 2>${outdir}/tmp_juicer_pre.log | \ 
 LC_ALL=C sort -k2,2d -k6,6d -T ${outdir} --parallel=36 -S500G | \
awk 'NF' > ${outdir}/alignments_sorted.txt.part && mv ${outdir}/alignments_sorted.txt.part ${outdir}/alignments_sorted.txt

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
$juicer_tools_pre ${outdir}/alignments_sorted.txt ${outdir}/${out}.hic.part ${outdir}/${out}_scaffolds_final.chrom.sizes && {mv ${outdir}/${out}.hic.part ${outdir}/${out}.hic

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
$juicer_tools_pre ${outdir}/${out}_JBAT.txt ${outdir}/${out}_JBAT.hic.part ${outdir}/${out}_JBAT.chrom.sizes && mv ${outdir}/${out}_JBAT.hic.part ${outdir}/${out}_JBAT.hic

if [ $? -eq 0 ] ; then
echo 'JBAT mode success'
elif [ $? -eq 1 ] ; then
echo 'error 1: JBAT mode'
else
echo 'error non-1: JBAT mode'
fi

#next steps involve manual curation with Juicebox, which is a GUI, so gonna do that in a later step
