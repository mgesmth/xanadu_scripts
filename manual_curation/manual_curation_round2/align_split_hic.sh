#!/bin/bash
#SBATCH -J alnhic_array
#SBATCH -p general
#SBATCH -q general
#SBATCH -n 1
#SBATCH -c 8
#SBATCH --mem=20G
#SBATCH --array=[0-299]%50
#SBATCH -o %x.%j.%a.out
#SBATCH -e %x.%A.%a.err

set -e

echo "`date`[M]: Host Name: `hostname`"
module load bwa/0.7.17
module load samtools/1.19

home=/home/FCAM/msmith
scratch=/scratch/msmith
core=/core/projects/EBP/smith
fq_dir=${scratch}/hic_split
bam_dir=${scratch}/hic_bams
ref=${core}/CBP_assemblyfiles/interior_primary_final.fa
ref_name=$(basename ${ref})

cd ${fq_dir}
fqs=($(cat fastqs.txt))
r1=${fqs[$SLURM_ARRAY_TASK_ID]}
r1_string="_R1"
name=${r1//$r1_string/}
r2=$(echo "$r1" | sed 's/R1/R2/')
out=$(echo "$name" | sed 's/fastq.gz/bam/')
sampleName="HiC_sample"
libraryName="HiC_library"

rg="@RG\\tID:${name}\\tSM:${sampleName}\\tPL:LS454\\tLB:${libraryName}"

echo -e "`date`[M]: Welcome to task ${SLURM_ARRAY_TASK_ID}."
echo -e "`date`[M]: We are aligning ${r1} and ${r2} to ${ref_name}.\n"

bwa mem -SP5M -t 4 -R "$rg" "$ref" "$r1" "$r2" | \
samtools sort -n -@ 4 -m 2500M -O "bam" -o "${bam_dir}/${out}"

echo -e "\n`date`:[M]: Alignment complete. Removing fastqs for disk..."
rm "$r1" "$r2"
echo -e "\n`date`:[M]: Done."
