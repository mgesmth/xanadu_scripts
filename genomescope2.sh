#!/bin/bash
#SBATCH --job-name=gs2
#SBATCH -p general
#SBATCH -q general
#SBATCH --mem=150G
#SBATCH -c 18
#SBATCH -d afterok:9030334
#SBATCH --mail-type=ALL
#SBATCH --mail-user=meg8130@student.ubc.ca
#SBATCH -o gs2.%j.out
#SBATCH -e gs2.%j.err

echo `hostname`

module load meryl/1.4.1
module load R/4.2.2
export PATH="/home/FCAM/msmith/R/x86_64-pc-linux-gnu-library/4.2:$PATH"
export PATH="/core/projects/EBP/smith/bin/genomescope2.0:$PATH"

meryldb=/core/projects/EBP/smith/merqury_out/intDF_hifi_CBP.meryl
mkdir /home/FCAM/msmith/genomescope2
outdir=/home/FCAM/msmith/genomescope2

meryl histogram threads=18 k=21 ${meryldb} > ${outdir}/intDF_hifi_CBP.meryl.hist
genomescope.R -i ${outdir}/intDF_hifi_CBP.meryl.hist -o ${outdir} -k 21
