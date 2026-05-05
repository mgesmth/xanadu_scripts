library(BatchMap)
library(readr)

args <- commandArgs(trailingOnly = TRUE)
wd=args[1]
input_file=args[2]
image=args[3]

setwd(wd)

load("onemap_functions_for_batchmap.RData")

outcross <- read.outcross2(input_file)
bins <- find.bins(outcross, exact = FALSE)
outcross_clean <- create.data.bins(outcross, bins)
save.image("binned_preseg.RData")
print("[M]: Saved binned pre-seg dist.")

#test segregation
seg_test <- test.segregation_outcross(outcross_clean)
png("seg_test_maf.png")
plot(seg_test)
dev.off()

#get distorted markers
seg_failed <- select.segreg(seg_test, distorted = TRUE)
seg_dist <- data.frame(chr=c(),pos=c())
for (i in 1:length(seg_failed)){
  x=strsplit(seg_failed[i],"_")
  scaff=paste(x[[1]][1],x[[1]][2],x[[1]][3],x[[1]][4],sep="_")
  pos=x[[1]][5]
  seg_dist <- rbind(seg_dist,data.frame(
    chr=scaff,
    pos=pos
  ))
}

write_tsv(seg_dist,file="seg_distort_snps_maf.tsv")
rm(seg_dist)

seg_passed=select.segreg(seg_test, distorted = TRUE)


#estimate two-point r
LOD=suggest_lod(outcross_clean)
LOD=12

twopt_table <- rf.2pts(outcross_clean,LOD=LOD,max.rf=0.35)

#find linkage groups
twoopt_table_segpass=make.seq(twopt_table,seg_passed)

linkage_groups <- group(twoopt_table_segpass,"all"))

print(linkage_groups,detailed=F)

LG_list <- list()
for(i in 1:13){
  print(i)
  LG_list[[paste("LG",i,sep="_")]] <- make.seq(linkage_groups,i)
}

save.image(image)
