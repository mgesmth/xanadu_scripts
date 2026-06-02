library(BatchMap)

args <- commandArgs(trailingOnly = TRUE)
wd <- args[1]
LG <- args[2]
cores <- args[3]

setwd(wd)

#load up linkage group data
load("LGs_created_maxrf0.25_LOD12.RData")

LG_cur<-LG_list[[LG]]

##order markers
LG_rec<-record.parallel(LG_cur,times=10,cores=cores)

#get a batch size
batch_size <- pick.batch.sizes(LG_rec, 
                 size = 50, 
                 overlap = 30, 
                 around = 10)

#now make the map!
rip.cores <- cores/2
map <- map.overlapping.batches(input.seq=LG_cur,
                               size=batch_size,
                               overlap=30,
                               fun.order=ripple.ord,
                               phase.cores=2,
                               ripple.cores=rip.cores,
                               ws=10,
                               max.dist = 25,
                               max.tries = 3,
                               min.tries = 1,
                               method="one",
                               optimize="likelihood",
                               verbosity=c("order","batch"))
#save results
save(map,file=paste(LG,"DFI_Rippled_Map.RData",sep="_"))