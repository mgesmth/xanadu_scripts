#!/bin/bash
#SBATCH --partition=general
#SBATCH --qos=general
#SBATCH --cpus-per-task=4
#SBATCH --nodes=1
#SBATCH --mem=20G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=meg.smith@ubc.ca
#SBATCH -o squash_%j.out
#SBATCH -e squash_%j.err

echo `hostname`

tar -cvzf other.tar.gz other
