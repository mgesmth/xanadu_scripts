library(BatchMap)

args <- commandArgs(trailingOnly = TRUE)
wd=args[1]
input_file=args[2]

setwd(wd)

load("onemap_functions_for_batchmap.RData")

outcross <- read.outcross2(input_file)
bins <- find.bins(outcross, exact = FALSE)
outcross_clean <- create.data.bins(outcross, bins)

#estimate two-point r
LOD=suggest_lod(outcross_clean)
twopt_table <- rf.2pts(outcross_clean,LOD=LOD,max.rf=0.35)

#find linkage groups
linkage_groups <- group(make.seq(input.obj = twopt_table, "all"),
                        LOD = LOD, max.rf = 0.35)
print(linkage_groups,detailed=F)

LG_list <- list()
for(i in 1:13){
  print(i)
  LG_list[[paste("LG",i,sep="_")]] <- make.seq(linkage_groups,i)
}

save.image("LGs_created.RData")
