#!/bin/bash

#STEP1: Index reference and generate site positions file
./prep_forjuicer.sh

#STEP2: Splitting fastq files ----
./split_hic_fastqs.sh

#STEP3: Align split fastqs as an array to speed up process ----
./align_split_hic.sh

#STEP4: Merge alignments and clean up ----
