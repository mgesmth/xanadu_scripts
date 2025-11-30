#!/bin/bash
#SBATCH -J alnhic_array
#SBATCH -p general
#SBATCH -q general
#SBATCH -n 1
#SBATCH -c 10
#SBATCH --mem=40G
#SBATCH --array=[0-298]%20
#SBATCH -o %x.%A.%a.out
#SBATCH -e %x.%A.%a.err

set -e

echo "`date`[M]: Host Name: `hostname`"
module load bwa/0.7.17
module load samtools/1.20

home=/home/FCAM/msmith
scratch=/scratch/msmith
core=/core/projects/EBP/smith
sandbox=/sandbox/msmith
fq_dir=${scratch}/hic_split
bam_dir=${sandbox}/hic_bams
ref=${core}/CBP_assemblyfiles/interior_primary_final.fa
ref_name=$(basename ${ref})
export SLURM_ARRAY_TASK_ID=$SLURM_ARRAY_TASK_ID
cd ${fq_dir}
fqs=($(cat fastqs_r1_299.txt))
r1=${fqs[$SLURM_ARRAY_TASK_ID]}
r1_string="_R1"
name=${r1//$r1_string/}
r2=$(echo "$r1" | sed 's/R1/R2/')
out="${name//.gz/}.bam"
sampleName="HiC_sample"
libraryName="HiC_library"
gid="intdf137"
site="Arima"
threads=6
jd=${sandbox}/juicer_formanualcur
rg="@RG\\tID:${name}\\tSM:${sampleName}\\tPL:LS454\\tLB:${libraryName}"

echo -e "`date`[M]: Welcome to task ${SLURM_ARRAY_TASK_ID}."
echo -e "`date`[M]: We are aligning ${r1} and ${r2} to ${ref_name}.\n"

bwa mem -SP5M -t 8 -R "$rg" "$ref" "$r1" "$r2" | samtools view -b -o "${bam_dir}/${name//.gz/}.unsorted.bam" -
samtools sort -n -@ 8 -m 2500M -O "bam" -o "${bam_dir}/${out}" "${bam_dir}/${name//.gz/}.unsorted.bam" && rm "${bam_dir}/${name//.gz/}.unsorted.bam"

echo -e "\n`date`:[M]: Alignment complete. Removing fastqs for disk and moving alignment file..."
rm "$r1" "$r2"
touch ${jd}/work/intdf137/splits${r1//.gz/}
touch ${jd}/work/intdf137/splits${r2//.gz/}
mv "${bam_dir}/${out}" ${jd}/work/intdf137/splits/

#echo "`date`:[M]: Beginning juicer chimeric task $SLURM_ARRAY_TASK_ID."
#cd ${jd}

#${jd}/scripts/juicer_justchimeric.sh -f --assembly -g "$gid" -d "${jd}/work/intdf137" -s "$site" -S chimeric \
#-p references/intdf137.chrom.sizes -y restriction_sites/intdf137_Arima.txt \
#-z references/interior_primary_final.fa -D "$jd" -t "$threads"

#echo -e "`date`:[M]: Juicer chimeric processing task $SLURM_ARRAY_TASK_ID complete."
