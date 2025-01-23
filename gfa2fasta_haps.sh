#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=12
#SBATCH --partition=general
#SBATCH --qos=general
#SBATCH --mail-type=ALL
#SBATCH --mem=90G
#SBATCH --mail-user=meg.smith@ubc.ca
#SBATCH -o gfa2fasta_%j.out
#SBATCH -e gfa2fasta_%j.err

awk '/^S/{print ">"$2"\n"$3}' intDF011.asm.hic.hap1.p_ctg.gfa | fold > intDF011.asm.hic.hap1.p_ctg.fasta
awk '/^S/{print ">"$2"\n"$3}' intDF011.asm.hic.hap2.p_ctg.gfa | fold > intDF011.asm.hic.hap2.p_ctg.fasta
#in GFA files, the "segment" (i.e. actual sequence, or contig) starts with S. So finding all lines starting with
#S, print >, col $2 (which is the contig name) and then on the next line, $3 (the sequence)
#fold line wraps the file
