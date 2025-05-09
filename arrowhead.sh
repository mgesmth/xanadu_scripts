#!/bin/bash
#SBATCH -J juicer_arrowhead
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 12
#SBATCH --mem=250G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=meg8130@student.ubc.ca
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err
