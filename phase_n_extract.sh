#!/bin/bash

##LOAD MODULES
module load Hifiasm/0.24.0
export PATH="/core/projects/EBP/smith/bin/minigraph:$PATH"
export PATH="/core/projects/EBP/smith/bin/gfatools:$PATH"

##VARIABLES
home=/home/FCAM/msmith
core=/core/projects/EBP/smith
scratch=/scratch/msmith
minigraph_out=${core}/minigraph_out
hifiasm_out=${core}/hifiasm_out/phasing
h1=${home}/hiC_data/allhiC_R1.fastq.gz
h2=${home}/hiC_data/allhiC_R2.fastq.gz
pb=/seqdata/EBP/plant/Pseudotsuga_menziesii/intDF_allhifi_trim.fastq.gz


##RUN HIFIASM TO GET PHASED HAPLOTYPES
hifiasm -o ${hifiasm_out}/interior_dougfir_phased.asm -t36 --h1 $h1 --h2 $h2 $pb

##RUN MINIGRAPH TO ALIGN HAPLOTYPES TO PRIMARY/ALTERNATE SCAFFOLDED ASSEMBLIES
minigraph -cxggs -t35 ${minigraph_out}/interior_primary_alternate.gfa \
${hifiasm_out}/interior_dougfir_phased.asm.hic.hap1.p_ctg.gfa \
${hifiasm_out}/interior_dougfir_phased.asm.hic.hap2.p_ctg.gfa \
> ${minigraph_out}/prim_alt_h1_h2.gfa

##EXTRACT HAPLOTYPE SPECIFIC SUBGRAPHS AND CONVERT TO FASTA 

