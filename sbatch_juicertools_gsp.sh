#!/bin/bash
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 8
#SBATCH --mem=80G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=meg8130@student.ubc.ca
#SBATCH -o juicer_sites_test.%j.out
#SBATCH -e juicer_sites_test.%j.err

echo `hostname`

module load python/3.10.1
module load bwa/0.7.17
module load juicer/1.22.01
module load pairtools/0.2.2
export PATH="/home/FCAM/msmith/scripts:$PATH"
topdir=/core/projects/EBP/smith/juicer_primary
pairs=${topdir}/test_juicertools.pairs
site="Arima"
gid="interior_primary_test"
gpath=${topdir}/references/test_juicertools.fa
output="${topdir}/test_juicertools"

make_contact_maps_generate_site_positions.sh \
	-t 24 \
	-d "${topdir}" \
	-c "${pairs}" \
	-s "${site}" \
	-g "${gid}" \
	-z "${gpath}" \
	-x "/scratch/msmith" \
	-o "${output}"
