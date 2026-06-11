library(BatchMap)

args <- commandArgs(trailingOnly = TRUE)
wd <- args[1]
LG <- args[2]
cores <- as.numeric(args[3])
ripple_tries <- as.numeric(args[4])
ws <- as.numeric(args[5])
method <- args[6] #'one' or 'all'

setwd(wd)
descrip=paste0(LG,"_justRippledMap_ripple",ripple_tries,"_ws",ws,"_method",method)
dir.create(descrip)
outdir=descrip

#load up linkage group data
load("LGs_created_maxrf0.25_LOD10_cleaned.RData")
load("onemap_functions_for_batchmap.RData")

LG_cur<-LG_list_clean[[LG]]

print("[M]: Getting a batch size...")
#get a batch size
batch_size <- pick.batch.sizes(LG_cur, 
                 size = 50, 
                 overlap = 30, 
                 around = 10)

print("[M]: Now making the maps!")
print("[M]: Unrippled map...")
map1 <- map.overlapping.batches(input.seq=LG_rec,
    size=batch_size,
    phase.cores=4,
    overlap=30)
print(paste0("[M]: Map log-likelihood: ",map1$Map$seq.like))
write.map(map1$Map,file=file.path(descrip,"unrippled_map.txt"))
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

print("[M]: Rippled map...")
#now make the map!
rip.cores <- round(cores/2)
map2 <- map.overlapping.batches(input.seq=LG_cur,
                               size=batch_size,
                               overlap=30,
                               fun.order=ripple.ord,
                               phase.cores=2,
                               ripple.cores=rip.cores,
                               ws=ws,
                               max.dist = 15,
                               max.tries=tries,
                               min.tries=3,
                               optimize="likelihood",
                               verbosity=c("batch"),
                               method=method,
                               no_reverse=FALSE)

print(paste0("[M]: Map log-likelihood: ",map2$Map$seq.like))
write.map(map2$Map,file=file.path(descrip,"rippled_map.txt"))
map2$Map$data.name <- outcross_clean
map2$Map$twopt <- twopt_table
png(file.path(outdir,paste0(LG,"_rippled_rfheatmap",".png")),
    width=960,height=960)
rf_graph_table(input.seq=map2$Map, display=FALSE, 
    lab.xy=c(paste0("Marker (n=",length(map2$Map$seq.num),")"),
        paste0("Marker (n=",length(map2$Map$seq.num),")")),
    mrk.axis="none",base.size=22)
dev.off()
map2$Map$data.name <- "outcross_clean"
map2$Map$twopt <- "twopt_table"

#add twopt and outcross objects to map
map2=map
map2$Map$data.name=outcross_clean
map2$Map$twopt=twopt_table

save.image(file=file.path(outdir,
    paste(descrip,"DFI_Rippled_Map.RData",sep="_")))