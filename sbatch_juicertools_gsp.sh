#!/bin/bash
#SBATCH -p himem
#SBATCH -q himem
#SBATCH -c 24
#SBATCH --mem=250G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=meg8130@student.ubc.ca
#SBATCH -o juicer_sites.%j.out
#SBATCH -e juicer_sites.%j.err

echo `hostname`

module load python/3.10.1
module load bwa/0.7.17
module load juicer/1.22.01
module load pairtools/0.2.2
export PATH="/home/FCAM/msmith/scripts:$PATH"
topdir=/core/projects/EBP/smith/juicer_primary
pairs=/scratch/msmith/interior_primary_hiCaln_nodups.pairs
site="Arima"
gid="interior_primary"
gpath=${topdir}/references/interior_primary_final.fa
output="${topdir}/interior_primary_contacts"

make_contact_maps_generate_site_positions.sh \
	-t 24 \
	-d "${topdir}" \
	-c "${pairs}" \
	-s "${site}" \
	-g "${gid}" \
	-z "${gpath}" \
	-x "/scratch/msmith" \
	-o "${output}"
