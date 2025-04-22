#!/bin/bash
#SBATCH -p himem
#SBATCH -q himem
#SBATCH -c 24
#SBATCH --mem=150G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=meg8130@student.ubc.ca
#SBATCH -o juicebox_tools.%j.out
#SBATCH -e juicebox_tools.%j.err

echo `hostname`

module load python/3.10.1
module load bwa/0.7.17
module load juicer/1.22.01
export PATH="/home/FCAM/msmith/scripts:$PATH"
topdir=/core/projects/EBP/smith/juicer_intDF011
pairs=${topdir}/intDF011.nodups.pairs
site="Arima"
gid="intDF011"
gpath=${topdir}/references/intDF011_scaffolds_final.fa
output="${topdir}/intDF011_contacts"

make_contact_maps_juiceboxtools.sh \
	-t 24 \
	-d "${topdir}" \
	-c "${pairs}" \
	-s "${site}" \
	-g "${gid}" \
	-z "${gpath}" \
	-x "/scratch/msmith" \
	-o "${output}"
