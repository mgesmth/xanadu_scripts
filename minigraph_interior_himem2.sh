#!/bin/bash
#SBATCH --job-name=minigraph
#SBATCH --partition=himem2
#SBATCH --qos=himem
#SBATCH --cpus-per-task=24
#SBATCH --mem=750G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=meg8130@student.ubc.ca
#SBATCH -o minigraph_interior.%j.out
#SBATCH -e minigraph_interior.%j.err

echo `hostname`

home=/home/FCAM/msmith
core=/core/projects/EBP/smith
prim_scaff1=${core}/CBP_assemblyfiles/interior_primary_scaffold1.fa
alt=${core}/CBP_assemblyfiles/interior_alternate_1Mb.fa
coa=${core}/coastal/coastalDF_scaffrenamed_sorted_1Mb.fa
out=${home}/minigraph_out/interior_primalt_toscaff1

#test - succeeded
#test=${core}/bin/minigraph/test
#test_gfa=${test}/MT.gfa
#human=${test}/MT-human.fa
#chimp=${test}/MT-chimp.fa
#orang=${test}/MT-orangA.fa
#test_out=${test}/test

#EXEC
module load zlib/1.2.11
export PATH="${core}/bin/minigraph-0.21:$PATH"
export PATH="${core}/bin/gfatools:$PATH"

#test real variables - succeeded
#ls ${prim}
#ls ${alt}
#echo ${out}

#test command
#minigraph -cxggs -l 10k ${test_gfa} ${human} ${chimp} ${orang} > "${test_out}.gfa"
#gfatools bubble "${test_out}.gfa" > "${test_out}.bed"

minigraph -cxggs -t 24 ${prim_scaff1} ${alt} ${coa} > "${out}.gfa"
gfatools bubble "${out}.gfa" > "${out}.bed"
