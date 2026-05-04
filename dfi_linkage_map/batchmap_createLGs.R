library(BatchMap)

args <- commandArgs(trailingOnly = TRUE)
wd=args[1]
input_file=args[2]

setwd(wd)

outcross <- read.outcross2(input_file)

#estimate two-point r
twopt_table <- rf.2pts(outcross)
#find linkage groups
#suggest_lod from onemap; batchmap function doesn't work
suggest_lod <- function(x) {
  if (inherits(x, c("sequence", "onemap","outcross"))) {
    if (inherits(x, c("onemap","outcross")))
      num.tests <- choose(x$n.mar, 2)
    if (inherits(x, "sequence"))
      num.tests <- choose(length(x$seq.num), 2)
    LOD <- 0.2172 * qchisq(1 - 0.05/num.tests, 1)
    return(LOD)
  }
  else stop("This is not a onemap object with raw data")
}
LOD=suggest_lod(outcross)

linkage_groups <- group(make.seq(input.obj = twopt_table, "all"),
                        LOD = LOD, max.rf = 0.35)
print(linkage_groups,detailed=F)

LG_list <- list()
for(i in 1:13){
  print(i)
  LG_list[[paste("LG",i,sep="_")]] <- make.seq(linkage_groups,i)
}

save.image("LGs_created.RData")
