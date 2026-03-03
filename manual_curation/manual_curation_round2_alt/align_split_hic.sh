#!/bin/bash
#SBATCH -J alnhic_array
#SBATCH -p general
#SBATCH -q general
#SBATCH -n 1
#SBATCH -c 10
#SBATCH --mem=40G
#SBATCH --array=[0-299]
#SBATCH -o %x.%A.%a.out
#SBATCH -e %x.%A.%a.err

set -e

echo "`date`[M]: Host Name: `hostname`"
module load bwa/0.7.17
module load samtools/1.20

home=/home/FCAM/msmith
scratch=/scratch/msmith
core=/core/projects/EBP/smith
fq_dir=${scratch}/hic_split
bam_dir=${scratch}/hic_bams
ref=${core}/CBP_assemblyfiles/interior_alternate_final.fa
ref_name=$(basename ${ref})
export SLURM_ARRAY_TASK_ID=$SLURM_ARRAY_TASK_ID
cd ${fq_dir}
fqs=($(cat fastqs.txt))
r1=${fqs[$SLURM_ARRAY_TASK_ID]}
r1_string="_R1"
name=${r1//$r1_string/}
r2=$(echo "$r1" | sed 's/R1/R2/')
out="${name//.gz/}.bam"
sampleName="HiC_sample"
libraryName="HiC_library"
gid="intdf137_alt"
site="Arima"
threads=6
jd=${core}/juicer_alt
rg="@RG\\tID:${name}\\tSM:${sampleName}\\tPL:LS454\\tLB:${libraryName}"

echo -e "`date`[M]: Welcome to task ${SLURM_ARRAY_TASK_ID}."
echo -e "`date`[M]: We are aligning ${r1} and ${r2} to ${ref_name}.\n"

bwa mem -SP5M -t 8 -R "$rg" "$ref" "$r1" "$r2" | samtools view -b -o "${bam_dir}/${name//.gz/}.unsorted.bam" -
samtools sort -n -@ 8 -m 2000M -O "bam" -o "${bam_dir}/${out}" "${bam_dir}/${name//.gz/}.unsorted.bam" && rm "${bam_dir}/${name//.gz/}.unsorted.bam"

echo -e "\n`date`:[M]: Alignment complete. Removing fastqs for disk and moving alignment file..."
rm "$r1" "$r2"
touch ${jd}/work/${gid}/fastq/${name//.fastq.gz/}_R1.fastq
touch ${jd}/work/${gid}/fastq/${name//.fastq.gz/}_R2.fastq
cd ${jd}/work/${gid}/splits
ln -s ../fastq/${name//.fastq.gz/}_R1.fastq .
ln -s ../fastq/${name//.fastq.gz/}_R2.fastq .
mv "${bam_dir}/${out}" ${jd}/work/${gid}/splits/
