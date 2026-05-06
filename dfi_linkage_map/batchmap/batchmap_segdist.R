library(BatchMap)
library(readr)

'''
find the markers without segregation distortion
'''

args <- commandArgs(trailingOnly = TRUE)
wd=args[1]
input_file=args[2]

setwd(wd)

load("onemap_functions_for_batchmap.RData")

outcross <- read.outcross2(input_file)

seg_test <- test.segregation_outcross(outcross)
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

#find good markers
seg_passed <- select.segreg(seg_test, distorted = FALSE)
write_tsv(data.frame(marker=seg_passed),file="seg_passed_markers_notbinned.tsv")

print("[M]: Done!")
