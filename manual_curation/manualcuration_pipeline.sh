#!/bin/bash

#STEP1: Splitting fastq files ----
./split_hic_fastqs.sh1

#STEP2: Align split fastqs as an array to speed up process ----
./align_split_hic.sh

#STEP3: Merge alignments and clean up ----
