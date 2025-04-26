#!/bin/bash
#SBATCH -p himem
#SBATCH -q himem
#SBATCH -c 36
#SBATCH --mem=500G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=meg8130@student.ubc.ca
#SBATCH -o juicer_tools.%j.out
#SBATCH -e juicer_tools.%j.err

echo `hostname`

module load python/3.10.1
module load bwa/0.7.17
module load juicer/1.22.01
export PATH="/home/FCAM/msmith/scripts:$PATH"
topdir=/core/projects/EBP/smith/juicer_primary
pairs=/scratch/msmith/interior_primary_hiCaln_nodups.pairs
site="Arima"
gid="interior_primary"
gpath=${topdir}/references/interior_primary_final.fa
output="${topdir}/interior_primary_contacts"

make_contact_maps_juiceboxtools.sh \
	-t 36 \
	-d "${topdir}" \
	-c "${pairs}" \
	-g "${gid}" \
	-s "${site}" \
	-z "${gpath}" \
	-x "/scratch/msmith" \
	-o "${output}"
