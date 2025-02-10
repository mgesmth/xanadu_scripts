#!/bin/bash
#SBATCH --partition=general
#SBATCH --qos=general
#SBATCH --cpus-per-task=8
#SBATCH --mem=100G
#SBATCH --mail-user=meg8130@student.ubc.ca
#SBATCH --mail-type=ALL
#SBATCH -o purgeconfig.%j.out
#SBATCH -e purgeconfig.%j.err

module load purge_dups/1.2.6
module load python/3.8.1

purge_scripts=/isg/shared/apps/purge_dups/1.2.6/scripts
home=/home/FCAM/msmith
purgedir=${home}/purge_dups

python3 ${purge_scripts}/pd_config.py -l $purgedir -n intDF011_config.json intDF011.asm.hic.p_ctg.fasta hififofn 

