#!/bin/bash
#SBATCH -J minigraph_call
#SBATCH -p himem2
#SBATCH -q himem
#SBATCH -c 24
#SBATCH --mem=1200G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=meg8130@student.ubc.ca
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

echo `hostname`

home=/home/FCAM/msmith
core=/core/projects/EBP/smith
scratch=/scratch/msmith

module load zlib/1.2.11
export PATH="${core}/bin/minigraph-0.21:$PATH"
export PATH="${core}/bin/gfatools:$PATH"

minidir=/home/FCAM/msmith/svs/minigraph_out
gfa=/home/FCAM/msmith/svs/minigraph_out/all_primscaff1split.gfa

minigraph -cxasm --call -t24 ${gfa} ${scratch}/interior_primary_bigscaffoldsplit.fa > ${minidir}/scaffold_primary_path.bed
#${home}/scripts/minigraph_callpath_scaffold.sh ${scratch}/interior_alternate_1Mb.fa ${minidir}/scaffold_alternate_path.bed
#${home}/scripts/minigraph_callpath_scaffold.sh ${scratch}/coastal_1Mb.fa ${minidir}/scaffold_coastal_path.bed
