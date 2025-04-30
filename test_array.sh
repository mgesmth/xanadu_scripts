#!/bin/bash
#SBATCH -J arraytest
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 1
#SBATCH --mem=1G
#SBATCH -p general
#SBATCH -q general
#SBATCH --array=[1-33]%10
#SBATCH -o %x_%A.%a.out
#SBATCH -e %x_%A.%a.err

scratch=/scratch/msmith
altdir=${scratch}/minigraph_prep/alternate_fastas
primdir=${scratch}/minigraph_prep/primary_fastas

echo "[M]: Host Name:" `hostname`
echo "[M]: This is minigraph task $SLURM_ARRAY_TASK_ID"

#Create an array containing the names of the PRIM fasta files to align
FILESPRIM=($(ls -1 ${primdir} | sort -g -t '_' -k2))

#Create an array containing the names of the ALT fasta files to align (in order of 1 to n)
FILESALT=($(ls -1 ${altdir} | sort -g -t '_' -k2))

#Get the names of the fasta files to be implicated in this array task
FA_REF=${FILESPRIM[$SLURM_ARRAY_TASK_ID]}
FA_QRY=${FILESALT[$SLURM_ARRAY_TASK_ID]}
OUT=$(echo "${FA_REF}_alternate")

echo $FA_REF $FA_GRY $OUT
echo "Proceeding with minigraph graph generation and SV calling for ${FA_REF} against ${FA_QRY}"
