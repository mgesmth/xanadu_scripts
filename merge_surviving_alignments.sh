#!/bin/bash
#SBATCH -J merge_surviving_alignments
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 12
#SBATCH --mem=56G
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err
