#!/bin/bash
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 12
#SBATCH --mem=50G
#SBATCH --mail-type=END
#SBATCH --mail-user=meg8130@student.ubc.ca
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

echo `hostname`

export PATH="/core/projects/EBP/smith/bin:$PATH"

vg stats -F /home/FCAM/msmith/minigraph_out/all_brokenscaffolds.gfa > vgstats.txt
