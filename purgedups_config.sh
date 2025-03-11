#!/bin/bash
#SBATCH --partition=himem2
#SBATCH --qos=himem
#SBATCH --mem=20G
#SBATCH --cpus-per-task=8
#SBATCH --mail-type=ALL
#SBATCH --mail-user=meg8130@student.ubc.ca
#SBATCH -o pd_config.%j.out
#SBATCH -e pd_config.%j.err

module load purge_dups/1.2.6
pd_scripts=/isg/shared/apps/purge_dups/1.2.6/scripts
home=/home/FCAM/msmith
contigs_dir=${home}/yahs/contigs
contigs=${contigs_dir}/intDF011.asm.hic.p_ctg.fasta

#config file for purge dups
${pd_scripts}/pd_config.py -l ${contigs_dir} -n intDF011_config.json $contigs ${contigs_dir}/pacbio.fofn
