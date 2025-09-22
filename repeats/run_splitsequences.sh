#!/bin/bash

#Had to run on Mantis not Xanadu - kept being unable to call on pandas due to, I think, a root package issue

module load python/3.8.1

home=/home/FCAM/msmith
repdir=${home}/repeats_mancur

cd ${repdir}
mkdir concatenated_results
cd concatenated_results
mkdir fa.out_files
cp ../first_20/*.fa.out fa.out_files/
cp ../above_1Mb/*.fa.out fa.out_files/
cp ../below_1Mb/*.fa.out fa.out_files/
cp ../first_20/*.fa.tbl fa.tbl_files/
cp ../above_1Mb/*.fa.tbl fa.tbl_files/
cp ../below_1Mb/*.fa.tbl fa.tbl_files/

python ${home}/scripts/repeats/process_split_RMoutput.py
