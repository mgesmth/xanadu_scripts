library(BatchMap)

args <- commandArgs(trailingOnly = TRUE)
wd=args[1]
input_file=args[2]

setwd(wd)

outcross <- read.outcross2(input_file)

#estimate two-point r
twopt_table <- rf.2pts(outcross)
#find linkage groups
linkage_groups <- group(make.seq(input.obj = twopt_table, "all"),
                        LOD = 12)
print(linkage_groups,detailed=F)

LG_list <- list()
for(i in 1:13){
  print(i)
  LG_list[[paste("LG",i,sep="_")]] <- make.seq(linkage_groups,i)
}

save.image("LGs_created.RData")