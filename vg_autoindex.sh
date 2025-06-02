#!/bin/bash
#SBATCH -p himem2
#SBATCH -q himem
#SBATCH -c 20
#SBATCH --mem=100G
#SBATCH --mail-type=END
#SBATCH --mail-user=meg8130@student.ubc.ca
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

echo "[M]: Host Name: `hostname`"

sv=/home/FCAM/msmith/svs
core=/core/projects/EBP/smith
gfa=${sv}/vg/all_brokenscaffolds1.0.gfa
out=${sv}/vg/all_brokenscaffolds

export PATH="${core}/bin:$PATH"

base=$(basename ${gfa})
echo "[M]: Beginning vg autoindex on ${base}"
vg autoindex -p "$out" -g ${gfa} -T /scratch/msmith -M 100G -t 20
if [ $? -eq 0 ] ; then
	echo "[M]: vg autoindex of ${base} is complete. Exiting 0."
	exit 0
else
	echo "[E]: vg autoindex of ${base} exited with non-zero status."
	exit 1
fi
