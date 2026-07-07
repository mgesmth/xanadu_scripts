#!/bin/bash
#SBATCH -J 00.prep_genome
#SBATCH -c 12
#SBATCH --mem=36G
#SBATCH -o 98_log_files/%x_%j.out
#SBATCH -e 98_log_files/%x_%j.err

set -e
echo "[M]: Host Name: `hostname`"
module load singularity/3.9.2

LOG_FOLDER="98_log_files"
INFO="02_info_files"
GENOMEFOLDER="03_genome"
GENOME=$(ls -1 $GENOMEFOLDER/*{fasta,fa,fasta.gz,fa.gz} | xargs -n 1 basename)

cd $GENOMEFOLDER
if [[ ! -f ${GENOME} ]] ; then
	echo "[E]: Genome FASTA file not found. Please inspect your files."
	exit 1
else
	if [[ ! -f "${GENOME}.fai" ]] ; then
		echo "[M]: FAI not found. Indexing..."
		module load samtools/1.21-gcc-11.4.0-7lu5xjn
		samtools faidx ${GENOME}
		echo "[M]: Done FAI"
	else
		echo "[M]: FAI found."

	if [[ ! -f "${GENOME}.bwt" ]] ; then
		echo "[M]: BWA indices not found. Indexing..."
		module load bwa/0.7.17
		bwa index ${GENOME}
		echo "[M]: BWA indices created."
	else
		echo "[M]: BWA indices found."

	suf=$(echo "$GENOME" | awk '{n=split($1,m,".") ; print "." m[n]}')
	nosuf=$(echo "$GENOME" | sed "s/${suf}$//")

	if [[ ! -f "${nosuf}.dict" ]] ; then
		echo "[M]: Sequence Dictionary not found. Indexing..."
		module load picard/3.1.1
		java -jar $PICARD CreateSequenceDictionary -R $GENOME -O ${nosuf}.dict
		echo "[M]: Sequence dictionary created."
	else
		echo "[M]: Sequence dictionary created."

	echo "[M] All indices found and/or created."
fi
