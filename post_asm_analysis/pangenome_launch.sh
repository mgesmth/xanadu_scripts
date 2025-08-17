#!/bin/bash
#SBATCH -J minigraph_launch
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 2
#SBATCH --mem=2G
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

set -e
set -a
date
echo "[M]: Host Name: `hostname`"

home=/home/FCAM/msmith
core=/core/projects/EBP/smith
scratch=/scratch/msmith
prim=${scratch}/interior_primary_final_mancur_bigscaffoldsplit.fa
alt=${scratch}/interior_alternate_1Mb.fa
coast=${scratch}/coastal_1Mb.fa
prx="final_finalpangenome"
outdir=${core}/manual_curation_files/minigraph
if [[ ! -d ${outdir} ]] ; then
  mkdir ${outdir}
fi
log=${core}/manual_curation_files/log

##Generate pangenome graph ----
jid_gfa=`sbatch <<- HEADER | egrep -o -e "\b[0-9]+$"
#!/bin/bash
#SBATCH -J minigraph_graphgen
#SBATCH -p himem2
#SBATCH -q himem
#SBATCH -c 36
#SBATCH --mem=1000G
#SBATCH -o ${log}/%x.%j.out
#SBATCH -e ${log}/%x.%j.err
	
date
set -e
echo "[M]: Host Name: `hostname`"
echo "[M]: Beginning minigraph graph generation"

#executables
module load zlib/1.2.11
export PATH="${core}/bin/minigraph-0.21:$PATH"
export PATH="${core}/bin/gfatools:$PATH"

threads="$(getconf _NPROCESSORS_ONLN)"
prx="final_finalpangenome"
outdir=${core}/manual_curation_files/minigraph

#pangenome graph:
minigraph -cxggs -t 24 ${prim} ${alt} ${coast} > "${outdir}/${prx}.gfa"
#call bubbles (SVs)
gfatools bubble "${outdir}/${prx}.gfa" > "${outdir}/${prx}_unfiltered.bed"
#get stats on the pangenome graph (number of nodes/edges, etc.)
gfatools stat "${outdir}/${prx}.gfa" > "${outdir}/${prx}.stat"

if [[ $? -eq 0 ]] ; then
echo "[M]: Done."
exit 0
else
echo "[E]: Graph generation failed. Exit code $?"
fi
HEADER`

#Call paths through pangenome - neccesary to get the VCF files
##Call primary ----
jid_primcall=`sbatch <<- HEADER | egrep -o -e "\b[0-9]+$"
#!/bin/bash
#SBATCH -J minigraph_primcall
#SBATCH -d afterok:${jid_gfa}
#SBATCH -p himem2
#SBATCH -q himem
#SBATCH -c 24
#SBATCH --mem=1000G
#SBATCH -o ${log}/%x.%j.out
#SBATCH -e ${log}/%x.%j.err
	
date
set -e
echo "[M]: Host Name: `hostname`"
echo "[M]: Beginning minigraph call path (prim)"

#executables
module load zlib/1.2.11
export PATH="${core}/bin/minigraph-0.21:$PATH"
export PATH="${core}/bin/gfatools:$PATH"

threads="$(getconf _NPROCESSORS_ONLN)"
prx="final_finalpangenome"
outdir=${core}/manual_curation_files/minigraph

#call primary path
minigraph -cxasm --call -t "$threads" "${outdir}/${prx}.gfa" $prim > "${outdir}/${prx}_primcall.bed"

if [[ $? -eq 0 ]] ; then
echo "[M]: Done."
exit 0
else
echo "[E]: Prim call path failed. Exit code $?"
fi
HEADER`

##Call alternate ----
jid_altcall=`sbatch <<- HEADER | egrep -o -e "\b[0-9]+$"
#!/bin/bash
#SBATCH -J minigraph_altcall
#SBATCH -d afterok:${jid_gfa}
#SBATCH -p himem2
#SBATCH -q himem
#SBATCH -c 24
#SBATCH --mem=700G
#SBATCH -o ${log}/%x.%j.out
#SBATCH -e ${log}/%x.%j.err
	
date
set -e
echo "[M]: Host Name: `hostname`"
echo "[M]: Beginning minigraph call path (alt)"
module load zlib/1.2.11
export PATH="${core}/bin/minigraph-0.21:$PATH"
export PATH="${core}/bin/gfatools:$PATH"
threads="$(getconf _NPROCESSORS_ONLN)"
prx="final_finalpangenome"
outdir=${core}/manual_curation_files/minigraph

minigraph -cxasm --call -t "$threads" "${outdir}/${prx}.gfa" $alt > "${outdir}/${prx}_altcall.bed"

if [[ $? -eq 0 ]] ; then
echo "[M]: Done."
exit 0
else
echo "[E]: Alt call path failed. Exit code $?"
fi
HEADER`

##Call coastal ----
jid_coastcall=`sbatch <<- HEADER | egrep -o -e "\b[0-9]+$"
#!/bin/bash
#SBATCH -J minigraph_coastcall
#SBATCH -d afterok:${jid_gfa}
#SBATCH -p himem2
#SBATCH -q himem
#SBATCH -c 24
#SBATCH --mem=700G
#SBATCH -o ${log}/%x.%j.out
#SBATCH -e ${log}/%x.%j.err
	
date
set -e
echo "[M]: Host Name: `hostname`"
echo "[M]: Beginning minigraph call path (cost)"
module load zlib/1.2.11
export PATH="${core}/bin/minigraph-0.21:$PATH"
export PATH="${core}/bin/gfatools:$PATH"
threads="$(getconf _NPROCESSORS_ONLN)"
prx="final_finalpangenome"
outdir=${core}/manual_curation_files/minigraph

minigraph -cxasm --call -t "$threads" "${outdir}/${prx}.gfa" $coast > "${outdir}/${prx}_coastcall.bed"

if [[ $? -eq 0 ]] ; then
echo "[M]: Done."
exit 0
else
echo "[E]: Coast call path failed. Exit code $?"
fi
HEADER`

#Generate VCF
jid_vcf=`sbatch <<- HEADER | egrep -o -e "\b[0-9]+$"
#!/bin/bash
#SBATCH -J minigraph_bed2vcf
#SBATCH -d afterok:${jid_primcall},${jid_altcall},${jid_coastcall}
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 8
#SBATCH --mem=40G
#SBATCH -o ${log}/%x.%j.out
#SBATCH -e ${log}/%x.%j.err

set -e
date
echo "[M]: Host Name: `hostname`"
echo "[M]: Beginning minigraph call path (cost)"

#executables
module load java/17.0.2
export PATH="${core}/bin/minigraph-0.21:$PATH"
export PATH="${core}/bin/minigraph-0.21/mg-cookbook-v1_x64-linux:$PATH"
export PATH="${core}/bin/gfatools:$PATH"
k8_dir=/core/projects/EBP/smith/bin/minigraph-0.21/mg-cookbook-v1_x64-linux
misc_dir=${core}/bin/minigraph-0.21/misc
module load bedtools/2.29.0

prx="final_finalpangenome"
outdir=${core}/manual_curation_files/minigraph
prim_prefix=$(basename "$prim" | sed 's/.fa//')
alt_prefix=$(basename "$alt" | sed 's/.fa//')
coast_prefix=$(basename "$coast" | sed 's/.fa//')

mkdir ${scratch}/minigraph_tmp
cd ${scratch}/minigraph_tmp
cp "${outdir}/${prx}_primcall.bed" .
cp "${outdir}/${prx}_altcall.bed" .
cp "${outdir}/${prx}_coastcall.bed" .
if [[ -f "${prx}_primcall.bed" && -f "${prx}_altcall.bed" && -f "${prx}_coastcall.bed" ]] ; then
echo -e "${prim_prefix}.bed\n${alt_prefix}.bed\n${coast_prefix}.bed" > samples.txt
paste *.bed | ${k8_dir}/k8 ${misc_dir}/mgutils.js merge -s samples.txt - | gzip -c > "${prx}.sv.bed.gz"
if [[ $? -eq 0 ]] ; then
${k8_dir}/k8 ${misc_dir}/mgutils-es6.js merge2vcf -a2 -r0 "${prx}.sv.bed.gz" > "${outdir}/${prx}_unfiltered.sv.vcf"
if [[ $? -eq 0 ]] ; then

date
echo "[M]: SV VCF created. Filtering and cleaning up..."
unfvcf="${outdir}/${prx}_unfiltered.sv.vcf"

#Filtering for missing data then for where all three alleles are the reference allele
awk '/^#/ {print} !/^#/ && $10 != "." && $11 != "." && $12 != "." {print}' ${unfvcf} | \
awk '/^#/ {print} !/^#/ && $11 ~ /1:1/ || $12 ~ /1:1/ {print}' > "${outdir}/${prx}_filtered1.sv.vcf"

#one additional filter at the summary step, bear in mind
cd ..
rm -r minigraph_tmp

echo "[M]: Done cleanup. Beginning to filter bed files..."
cd ${outdir}

#get a bedfile with the coordinates of processed SVs (VCF file doesnt have end coordinate accessible for bedtools intersect)
awk 'BEGIN { OFS="\t" } /^#/ {next} !/^#/ {
split($8,m,";")
split(m[1],n,"=")
print $1,$2,n[2] }' "${prx}_filtered1.sv.vcf" > filtered_coordinates.bed

#intersect the path bedfiles with filtered coordinates to get only the SVs that are valid
bedtools intersect -F 1 -wa -a "${prx}_primcall.bed" -b filtered_coordinates.bed  > "${prx}_primcall_verified.bed" && \
bedtools intersect -F 1 -wa -a "${prx}_altcall.bed" -b filtered_coordinates.bed > "${prx}_altcall_verified.bed" && \
bedtools intersect -F 1 -wa -a "${prx}_coastcall.bed" -b filtered_coordinates.bed > "${prx}_coastcall_verified.bed" && \
bedtools intersect -F 1 -wa -a "${prx}_unfiltered.bed" -b filtered_coordinates.bed > "${prx}_verified.bed"

if [[ $? -eq 0 ]] ; then
echo "[M]: Done."
else
echo "[E]: Filtering of bed files failed. Exit code $?"
exit 1
fi

else
echo "[E]: Conversion of merged bed file to VCF failed. Exiting code $?"
exit 1
fi
else
echo "[E]: Merging of bed files failed. Exit code $?"
exit 1
fi
else
echo "[E]: Path bed files not found in temp directory. Exiting."
exit 1
fi

HEADER`

jid_catsvs=`sbatch <<- HEADER | egrep -o -e "\b[0-9]+$"
#!/bin/bash
#SBATCH -J categorize_svs
#SBATCH -d afterok:${jid_vcf}
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 8
#SBATCH --mem=48G
#SBATCH -o ${log}/%x.%j.out
#SBATCH -e ${log}/%x.%j.err

date
set -e
echo "[M]: Host Name: `hostname`"
echo "[M]: Beginning categorization of SVs"
module load python/3.8.1
cd ${core}/manual_curation_files/minigraph
cat_svs=${home}/scripts/categorize_svs.py
prx="final_finalpangenome"

python ${cat_svs} "${prx}_filtered1.sv.vcf" \
"${prx}_primcall_verified.bed" \
"${prx}_altcall_verified.bed" \
"${prx}_coastcall_verified.bed" \
"${prx}_verified.bed" \
"svs_categorized.tsv"

if [[ $? -eq 0 ]] ; then
echo "[M]: Done."
exit 0
else
echo "[E]: SV Categorization failed. Exit code $?"
fi
HEADER`

