
#code modified from Marie's run on the first version of intDF

#this is being run within a repeat_observer working dir - paths not absolute
library(RepeatOBserverV1)
library(tidyverse)
inpath="input_chrs/intDF_H0"
fname="intDF_H0"
outpath="output_chrs/intDF_H0"

x_cpu=24
pflag=FALSE
writeflag=FALSE
plotflag=FALSE

nam_list0 <- list.files(inpath)
nam_list1 <- tools::file_path_sans_ext(nam_list0)
nam_list1
nam_list2 <- stringr::str_split(nam_list1, "_", simplify =TRUE)
nam_list3 <- stringr::str_split(nam_list2[,3], "part", simplify =TRUE)
chr_list <- nam_list3[,1]

#Manual run on smallest chromosome
chromosome="chr10"

for (i in 1:10){
  if (i < 10) {
    nam<-paste0(fname,"_",chromosome,"part0",i)
    print(nam)
    run_plot_chromosome_parallel(nam=nam, fname=fname, inpath=inpath, outpath=outpath, pflag=pflag, plotflag=plotflag,  writeflag=writeflag, x_cpu=x_cpu)
    write_All_spec_DNAwalk(nam=nam, fname=fname, chromosome=chromosome, inpath=inpath, outpath=outpath)
    print(paste0("finished: ", nam))
  } else if (i == 10) {
    nam<-paste0(sp_name,"_",chromosome,"part",i)
    print(nam)
    run_plot_chromosome_parallel(nam=nam, fname=fname, inpath=inpath, outpath=outpath, pflag=pflag, plotflag=plotflag,  writeflag=writeflag, x_cpu=x_cpu)
    write_All_spec_DNAwalk(nam=nam, fname=fname, chromosome=chromosome, inpath=inpath, outpath=outpath)
    print(paste0("finished: ", nam))
  } else {
    stop("[E]: i variable not handled correctly. Exiting.")
  }
}

merge_spectra(fname=fname, chromosome=chromosome, inpath=inpath, outpath=outpath)
join_chromosome_parts(fname=fname, chromosome=chromosome, inpath=inpath, outpath=outpath)
run_summary_hist(chromosome=chromosome, fname=fname, inpath=inpath, outpath=outpath)
run_diversity_plots(chromosome=chromosome, fname=fname, inpath=inpath, outpath=outpath)
run_summary_plots(chromosome=chromosome, fname=fname, inpath=inpath, outpath=outpath)

print("[M]: all done processing Chr10")
