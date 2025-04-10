#!/bin/bash
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 1
#SBATCH --mem=2G
#SBATCH -o test_gsalign.%j.out
#SBATCH -e test_gsalign.%j.err

bin=/core/projects/EBP/smith/bin
export PATH="${bin}/GSAlign/bin:$PATH"
human=${bin}/minigraph-0.21/test/MT-human.fa
chimp=${bin}/minigraph-0.21/test/MT-chimp.fa
out=/home/FCAM/msmith/test_gsalign

/home/FCAM/msmith/scripts/gsalign.sh -t 1 -r ${human} -q ${chimp} -o ${out} -f aln
