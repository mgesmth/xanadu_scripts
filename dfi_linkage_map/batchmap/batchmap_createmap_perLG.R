library(BatchMap)

args <- commandArgs(trailingOnly = TRUE)
LG <- args[1]
cores <- as.numeric(args[2])

descrip=paste0(LG,"_maps")
dir.create(descrip)
outdir=descrip

#load up linkage group data
load("LGs_created_maxrf0.35_LOD8_cleaned.RData")
load("onemap_functions_for_batchmap.RData")

LG_cur<-LG_list_clean[[LG]]
LG_rec=record.parallel(LG_cur,times=20,cores=20)
if (as.numeric(tail(LG_rec$seq.num,n=1)) < as.numeric(head(LG_rec$seq.num,n=1))) {
    LG_rec1=LG_rec
    LG_rec=make.seq(twopt_table,rev(LG_rec1$seq.num))
}

print("[M]: Getting a batch size...")
#get a batch size
batch_size <- pick.batch.sizes(LG_cur, 
                 size = 50, 
                 overlap = 30, 
                 around = 10)

print("[M]: Now making the maps!")
print("[M]: Building denomic map...")
map1 <- map.overlapping.batches(input.seq=LG_cur,
    size=batch_size,
    phase.cores=4,
    overlap=30)
print(paste0("[M]: Map log-likelihood: ",map1$Map$seq.like))
write.map(map1$Map,file=file.path(descrip,"genomic_map.txt"))
map1$Map$data.name <- outcross_clean
map1$Map$twopt <- twopt_table
png(file.path(outdir,paste0(LG,"_genomic_rfheatmap",".png")),
    width=960,height=960)
rf_graph_table(input.seq=map1$Map, display=FALSE, 
    lab.xy=c(paste0("Marker (n=",length(map1$Map$seq.num),")"),
        paste0("Marker (n=",length(map1$Map$seq.num),")")),
    mrk.axis="none",base.size=22)
dev.off()
map1$Map$data.name <- "outcross_clean"
map1$Map$twopt <- "twopt_table"

print("[M]: Building record and rippled map...")
max.dist=kosambi(0.1)
rip.cores <- round(cores/2)
map2 <- map.overlapping.batches(input.seq=LG_rec,
                               size=batch_size,
                               overlap=30,
                               fun.order=ripple.ord,
                               phase.cores=2,
                               ripple.cores=rip.cores,
                               ws=10,
                               max.dist = max.dist,
                               max.tries=10,
                               min.tries=2,
                               optimize="likelihood",
                               verbosity=c("batch"),
                               method="one")

print(paste0("[M]: Map log-likelihood: ",map2$Map$seq.like))
write.map(map2$Map,file=file.path(descrip,"recomb_map.txt"))
map2$Map$data.name <- outcross_clean
map2$Map$twopt <- twopt_table
png(file.path(outdir,paste0(LG,"_recomb_rfheatmap",".png")),
    width=960,height=960)
rf_graph_table(input.seq=map2$Map, display=FALSE, 
    lab.xy=c(paste0("Marker (n=",length(map2$Map$seq.num),")"),
        paste0("Marker (n=",length(map2$Map$seq.num),")")),
    mrk.axis="none",base.size=22)
dev.off()

map2$Map$data.name <- "outcross_clean"
map2$Map$twopt <- "twopt_table"

save.image(file=file.path(outdir,
    paste(descrip,"DFI_Rippled_Map.RData",sep="_")))