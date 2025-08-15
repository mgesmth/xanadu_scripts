#!/bin/bash

if [[ ( $@ == "--help") ||  $@ == "-h" ]]
then
  echo "Usage: ./quast.sh </PATH/TO/OUTIR> </PATH/TO/ASM.fa>"
fi

outdir=$1
asm=$2
module load quast/5.2.0
quast=/isg/shared/apps/quast/5.2.0/quast.py
threads="$(getconf _NPROCESSORS_ONLN)"

python3 $quast -t ${threads} --split-scaffolds --large -o ${outdir} ${asm}
