#!/bin/bash

if [[ ( $@ == "--help") ||  $@ == "-h" ]]
then
    echo ""
    echo "Usage: ./alignhic_identifycontacts <PATH_TO_ASSEMBLY> <OUT_PREFIX>"
    echo ""
    echo "Requirements:"
    echo "	bwa"
    echo "	samtools"
    echo "	pairtools"
    echo ""
    echo "I recommend sending everything to scratch as these files can be massive."
    echo ""
	exit 0
fi

module load bwa/0.7.17
module load samtools/1.20
module load pairtools/0.2.2

home=/home/FCAM/msmith
core=/core/projects/EBP/smith
scratch=/scratch/msmith
assembly=$1
out_prefix=$2
hic_R1=${home}/hiC_data/allhiC_R1.fastq.gz
hic_R2=${home}/hiC_data/allhiC_R2.fastq.gz

PREPROC_BAM="${out_prefix}_preproc.bam"
NODUPS_BAM="${out_prefix}_nodups.bam"
NODUPS_PAIRS="${out_prefix}_nodups.pairs"

if [[ ${assembly} == *.fa ]]; then
	asm_prefix=`echo "${assembly}" | sed 's/.fa//g'`
elif [[	${assembly} == *.fasta ]]; then
	asm_prefix=`echo "${assembly}" | sed 's/.fasta//g'`
else
	echo "-> Assembly not in recognizable format (i.e., .fa or .fasta). Exiting."
fi

if [ ! -f "${assembly}.bwt" ]; then
        echo "-> BWA index not found. Indexing..."
        bwa index ${assembly}
        echo "-> Done."
else
    	echo "-> BWA index found."
fi

echo "-> Beginning alignment of Hi-C reads..."
bwa mem -SP5M -t 36 "${assembly}" "${hic_R1}" "${hic_R2}" | samtools view -bh -o "${PREPROC_BAM}"


if [ ! -f "${assembly}.fai" ]; then
	echo "-> Faidx not found. Indexing..."
	samtools faidx ${assembly}
	echo "-> Done."
	echo "-> Creating chrom.sizes file..."
	cut -f1-2 "${assembly}.fai" > "${asm_prefix}.chrom.sizes"
	echo "-> Done."
else
	echo "-> Faidx found."
	if [ ! -f "${asm_prefix}.chrom.sizes" ]; then
		echo "-> Chrom.sizes file not found. Creating..."
		cut -f1-2 "${assembly}.fai" > "${asm_prefix}.chrom.sizes"
		echo "-> Done."
	else
		echo "Chrom.sizes file found."
	fi
fi

CHROM_SIZES="${asm_prefix}.chrom.sizes"

echo "-> Beginning Pairtools pipeline."

pairtools parse --chroms-path "${CHROM_SIZES}" "${PREPROC_BAM}"
} | {
pairtools sort --nproc 24 --memory 350G --tmpdir ${scratch}
} | {
pairtools dedup
} | {
pairtools split --output-pairs ${NODUPS_PAIRS} --output-sam ${NODUPS_BAM}
}

if [ $? -eq 0 ]; then
	rm ${PREPROC_BAM}
	echo "-> Done."
	exit 0
else
	echo "-> Pairtools failed. Exiting."
	exit 1
fi
