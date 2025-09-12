#!/bin/bash
#SBATCH -J psmc
#SBATCH -p general
#SBATCH -q general
#SBATCH -c 18
#SBATCH --mem=86G
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err

set -e
date
echo '[M]: Host Name: `hostname`'

#allow control for ratio parameter and for if to run boostrapping or not
run_with_bootstrapping="FALSE"
ratio=5

OPTSTRING="b:r:"
while getopts ${OPTSTRING} opt
do
  case ${opt} in
    r) ratio=${OPTARG};;
    b) run_with_bootstrapping="TRUE";;
  esac
done

home=/home/FCAM/msmith
core=/core/projects/EBP/smith
scratch=/scratch/msmith
psmcdir=${home}/psmc
psmcfa=${psmcdir}/hifialn_merged.psmcfa
split_psmcfa=${psmcdir}/hifialn_merged_split.psmcfa

module load psmc/0.6.5

#note: if you already have a trial dir for the specified parameter, it will be overwritten
if [[ ! -d ${psmcdir}/trial_${ratio} ]] ; then
  mkdir ${psmcdir}/trial_${ratio}
  cd ${psmcdir}/trial_${ratio}
else
  cd ${psmcdir}/trial_${ratio}
  if [ ! -z "$( ls -A ${psmcdir}/trial_${ratio} )" ]; then
    rm *
  fi
fi

if [[ $run_with_bootstrapping == "TRUE"]] ; then
  splitfa "$psmcfa" > "$split_psmcfa"
  psmc -r ${ratio} -p "2+2+25*2+4+6" -o "interior_trial_${ratio}.psmc" "${psmcfa}"
  #-b option specifies bootstrapping (control number of bootstraps with seq command)
  seq 100 | xargs -i echo psmc -r ${ratio} -b -p "2+2+25*2+4+6" -o round-{}.psmc "$split_psmcfa" | sh
  cat "interior_trial_${ratio}.psmc" round-*.psmc > "interior_trial_${ratio}_combined.psmc"
  rm round-*.psmc "$split_psmcfa"
else
  psmc -r ${ratio} -p "2+2+25*2+4+6" -o "interior_trial_${ratio}.psmc" "${psmcfa}"
fi
