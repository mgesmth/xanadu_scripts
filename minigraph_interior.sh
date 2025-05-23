#!/bin/bash
#SBATCH --job-name=minigraph
#SBATCH --partition=himem2
#SBATCH --qos=himem
#SBATCH --cpus-per-task=24
#SBATCH --mem=650G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=meg8130@student.ubc.ca
#SBATCH -o minigraph_interior.%j.out
#SBATCH -e minigraph_interior.%j.err

echo `hostname`

home=/home/FCAM/msmith
core=/core/projects/EBP/smith
prim=/scratch/msmith/interior_primary_first15.fa
alt=${core}/CBP_assemblyfiles/interior_alternate_1Mb.fa
out=${home}/minigraph_out/interior_primalt_newopts

#test - succeeded
#test=${core}/bin/minigraph/test
#test_gfa=${test}/MT.gfa
#human=${test}/MT-human.fa
#chimp=${test}/MT-chimp.fa
#orang=${test}/MT-orangA.fa
#test_out=${test}/test

#EXEC
export PATH="${core}/bin/zlib-1.3.1:$PATH"
export PATH="${core}/bin/minigraph:$PATH"
export PATH="${core}/bin/gfatools:$PATH"

#test real variables - succeeded
#ls ${prim}
#ls ${alt}
#echo ${out}

#test command
#minigraph -cxggs -l 10k ${test_gfa} ${human} ${chimp} ${orang} > "${test_out}.gfa"
#gfatools bubble "${test_out}.gfa" > "${test_out}.bed"

minigraph -cxggs -t 24 -k21 --min-cov-mapq 20 -q 20 --gg-match-pen 10 ${prim} ${alt} > "${out}.gfa"
gfatools bubble "${out}.gfa" > "${out}.bed"
