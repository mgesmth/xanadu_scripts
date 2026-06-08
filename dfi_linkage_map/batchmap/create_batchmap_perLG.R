library(BatchMap)

args <- commandArgs(trailingOnly = TRUE)
wd <- args[1]
LG <- args[2]
cores <- as.numeric(args[3])
tries=as.numeric(args[4])
around=as.numeric(args[5])

setwd(wd)
descrip=paste0("tries",tries,"_around",around)

#load up linkage group data
load("LGs_created_maxrf0.25_LOD12.RData")
load("onemap_functions_for_batchmap_withgraph.RData")

LG_cur<-LG_list[[LG]]

print("[M]: Ordering markers...")
##order markers
LG_rec<-record.parallel(LG_cur,
    times=10,
    cores=cores,
    LOD=12,
    max.rf=0.25)

print("[M]: Done ordering markers. Getting a batch size...")
#get a batch size
batch_size <- pick.batch.sizes(LG_rec, 
                 size = 50, 
                 overlap = 30, 
                 around = around)

print("[M]: Now making the map!")
#now make the map!
rip.cores <- round(cores/2)
map <- map.overlapping.batches(input.seq=LG_rec,
                               size=50,
                               overlap=30,
                               fun.order=ripple.ord,
                               phase.cores=2,
                               ripple.cores=rip.cores,
                               ws=5,
                               max.dist = 15,
                               max.tries=tries,
                               min.tries=3,
                               optimize="likelihood",
                               verbosity=c("order","batch"))


#add twopt and outcross objects to map
map2=map
map2$Map$data.name=outcross_clean
map2$Map$twopt=twopt_table

outdir=paste0(LG,"_",descrip)
dir.create(outdir)

#create a heatmap
png(file.path(outdir,paste0(LG,"_rfheatmap_",descrip,".png")),
    width=960,height=960)
rf_graph_table(input.seq=map2$Map, display=FALSE, 
    lab.xy=c(paste0("Marker (n=",length(map2$Map$seq.num),")"),
        paste0("Marker (n=",length(map2$Map$seq.num),")")),
    mrk.axis="none",base.size=22)
dev.off()

#print save results
print(paste0("Map likelihood : ",map$Map$seq.like))

save(map,file=file.path(outdir,
    paste(descrip,"DFI_Rippled_Map.RData",sep="_")))