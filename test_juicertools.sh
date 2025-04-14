#!/bin/bash
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 4
#SBATCH --mem=64G
#SBATCH -o juicebox_tools.%j.out
#SBATCH -e juicebox_tools.%j.err

echo `hostname`

module load python/3.10.1
module load bwa/0.7.17
module load juicer/1.22.01
export PATH="/home/FCAM/msmith/scripts:$PATH"
topdir=/scratch/msmith/juicebox_tools_test
pairs=${topdir}/test.txt.gz
site="Arima"
gid="hg19"
gpath=${topdir}/references/Homo_sapiens_assembly19.fasta
output="${topdir}/test"

make_contact_maps_juiceboxtools.sh \
	-t 4 \
	-d "${topdir}" \
	-c "${pairs}" \
	-s "${site}" \
	-g "${gid}" \
	-z "${gpath}" \
	-o "${output}"
