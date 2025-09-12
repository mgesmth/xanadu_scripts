#!/bin/bash

indir=/media/megsmith/overflow/data/Interior_DougFir_HiFi/rawhifi_bams
files=`cat bams.txt`
outdir=/media/megsmith/overflow/data/Interior_DougFir_HiFi/CBPwrkflw_hifi

#pbmerge & bam2fastq ----
source /home/megsmith/anaconda3/bin/activate /home/megsmith/miniforge3/envs/pbtk
cd ${indir}
pbmerge -o ${outdir}/allhifi_merged.bam $files
cd ${outdir}
bam2fastq -o ${outdir}/allhifi_merged allhifi_merged.bam && rm allhifi_merged.bam
source /home/megsmith/anaconda3/bin/deactivate

#cutadapt
source /home/megsmith/anaconda3/bin/activate/ /home/megsmith/miniforge3/envs/cutadapt

cutadapt \
--anywhere ATCTCTCTCAACAACAACAACGGAGGAGGAGGAAAAGAGAGAGAT \
--anywhere ATCTCTCTCTTTTCCTCCTCCTCCGTTGTTGTTGTTGAGAGAGAT \
--error-rate 0.1 --overlap 35 --times 3 --revcomp --discard-trimmed \
-o ${outdir}/allhifi_merged_trimmed.fastq.gz ${outdir}/allhifi_merged.fastq.gz && rm allhifi_merged.fastq.gz
