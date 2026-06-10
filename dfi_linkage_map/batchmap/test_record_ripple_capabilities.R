library(BatchMap)

args=commandArgs(trailingOnly=T)
LG=args[1]

load("LGs_created_maxrf0.25_LOD10.RData")
load("onemap_functions_for_batchmap.RData")

dir="testing_algorithms"
setwd(dir)

LG_cur=LG_list[[LG]]

print(paste0("[M]: Building unordered map for LG ",LG))
#build map without ordering markers
size1=pick.batch.sizes(LG_cur,size=50,overlap=30,around=10)
map1=map.overlapping.batches(LG_cur,size=size1,phase.cores=4,overlap=30)
like1=map1$Map$seq.like
print(paste0("[M]: Map likelihood: ",like1))

print(paste0("[M]: Building ordered but unrippled map for LG ",LG))
#build map with RECORD ordering but no ripple
LG_rec=record.parallel(LG_cur,times=20,cores=20)
size2=pick.batch.sizes(LG_rec,size=50,overlap=30,around=10)
map2=map.overlapping.batches(LG_rec,size=size2,phase.cores=4,overlap=30)
like2=map2$Map$seq.like
print(paste0("[M]: Map likelihood: ",like2))

print(paste0("[M]: Building ordered and rippled map for LG ",LG))
#build map with RECORD ordering and rippling
map3=map.overlapping.batches(LG_rec,size=size2,phase.cores=2,overlap=30,ripple.cores=10,fun.order=ripple.ord,ws=10,
max.dist=25,max.tries=10,min.tries=1,optimize="likelihood",verbosity="batch",method="one")
like3=map3$Map$seq.like
print(paste0("[M]: Map likelihood: ",like3))

df=data.frame(lg=LG,no_order=like1,rec_noripple=like2,rec_ripple=like3)
readr::write_tsv(df,file=paste(LG,"test_record_ripple.tsv",sep="_"))