#!/bin/bash

module load R/4.1.2 seqkit/2.10.0 emboss/6.6.0

ro_scripts=/home/FCAM/msmith/scripts/repeat_observer
core=/core/projects/EBP/smith
ro_dir=${core}/repeat_observer
#export path to RO dir as the Setup file is there
export PATH="${ro_dir}:$PATH"
in_dir=${ro_dir}/input_chrs/intDF_H0
out_dir=${ro_dir}/output_chrs/intDF_H0

cd ${ro_dir}

Rscript ${ro_scripts}/test_repeatobserver_chr10.R
