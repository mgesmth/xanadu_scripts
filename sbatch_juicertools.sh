#!/bin/bash
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 8
#SBATCH --mem=40G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=meg8130@student.ubc.ca
#SBATCH -o juicer_tools_test.%j.out
#SBATCH -e juicer_tools_test.%j.err

echo `hostname`

module load python/3.10.1
module load bwa/0.7.17
module load juicer/1.22.01
export PATH="/home/FCAM/msmith/scripts:$PATH"
topdir=/core/projects/EBP/smith/juicer_primary
pairs=${topdir}/test_juicertools_reformatted.pairs
site="Arima"
gid="test_juicertools"
gpath=${topdir}/references/test_juicertools.fa
output="${topdir}/test_juicertools"

make_contact_maps_juiceboxtools.sh \
	-t 12 \
	-d "${topdir}" \
	-c "${pairs}" \
	-g "${gid}" \
	-s "${site}" \
	-z "${gpath}" \
	-x "/scratch/msmith" \
	-o "${output}"
