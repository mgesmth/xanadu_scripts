library(BatchMap)

args <- commandArgs(trailingOnly = TRUE)
wd <- args[1]
LG <- args[2]
cores <- as.numeric(args[3])

setwd(wd)

#load up linkage group data
load("LGs_created_maxrf0.25_LOD12.RData")
load("onemap_functions_for_batchmap_withgraph.RData")

LG_cur<-LG_list[[LG]]

print("[M]: Ordering markers...")
##order markers
LG_rec<-record.parallel(LG_cur,times=10,cores=cores)

print("[M]: Done ordering markers. Getting a batch size...")
#get a batch size
batch_size <- pick.batch.sizes(LG_rec, 
                 size = 50, 
                 overlap = 30, 
                 around = 10)

print("[M]: Now making the map!")
#now make the map!
rip.cores <- round(cores/2)
map <- map.overlapping.batches(input.seq=LG_cur,
                               size=batch_size,
                               overlap=30,
                               fun.order=ripple.ord,
                               phase.cores=2,
                               ripple.cores=rip.cores,
                               ws=10,
                               max.dist = 25,
                               min.tries = 1,
                               optimize="likelihood",
                               verbosity=c("order","batch"))

#add twopt and outcross objects to map
map$Map$data.name=outcross_clean
map$Map$twopt=twopt_table

#create a heatmap
png(paste0(LG,"_rfheatmap.png"),width=960,height=960)
rf_graph_table(input.seq=map$Map, display=FALSE, 
    lab.xy=c(paste0("Marker (n=",length(map$Map$seq.num),")"),
        paste0("Marker (n=",length(map$Map$seq.num),")")),
    mrk.axis="none",base.size=22)
dev.off()

#save results
save(map,file=paste(LG,"DFI_Rippled_Map.RData",sep="_"))