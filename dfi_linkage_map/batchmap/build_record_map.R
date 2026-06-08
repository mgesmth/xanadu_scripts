library(BatchMap)

load("LGs_created_maxrf0.25_LOD12.RData")
load("onemap_functions_for_batchmap_withgraph.RData")

LG_cur<-LG_list[[LG]]
cores=20
print("[M]: Ordering markers...")
##order markers
LG_rec<-record.parallel(LG_cur,
    times=20,
    cores=cores,
    LOD=12,
    max.rf=0.25,
    tol=1e-06)

print(LG_rec)
try_map=map(LG_rec,phas)
save(try_map,file="justrec_map_LG11.RData")