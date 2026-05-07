library(BatchMap)

args <- commandArgs(trailingOnly = TRUE)
wd=args[1]
input_file=args[2]
max_rf=as.double(args[3])
LOD=as.double(args[4])

setwd(wd)

load("onemap_functions_for_batchmap.RData")

outcross <- read.outcross2(input_file)
bins <- find.bins(outcross, exact = FALSE)
outcross_clean <- create.data.bins(outcross, bins)

#estimate two-point r
twopt_table <- rf.2pts(outcross_clean,LOD=LOD,max.rf=max_rf)

#find linkage groups
linkage_groups <- group(make.seq(input.obj = twopt_table, "all"),
                        LOD = LOD, max.rf = max_rf)
print(linkage_groups,detailed=F)

LG_list <- list()
for(i in 1:13){
  print(i)
  LG_list[[paste("LG",i,sep="_")]] <- make.seq(linkage_groups,i)
}

image=paste0("LGs_created_maxrf",max_rf,"_LOD",LOD,".RData")

save.image(image)
