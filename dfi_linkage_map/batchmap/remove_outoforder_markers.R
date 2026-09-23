library(BatchMap)

LG <- commandArgs(trailingOnly=TRUE)[1]

load(paste0("map_",LG,"_reord.RData"))
sorted_order <- sort(revised_order)
ok_order <- c()
for (i in 1:length(revised_order)) {
	rev=revised_order[i]
	sor=sorted_order[i]
	diff=rev-sort
	if (diff == 0) {
		ok_order=append(ok_order,rev)
		next
	} else {
		next
	}
}
colin.marks <- make.seq(twopot_table,ok_order)
size.colin <- pick.batch.sizes(colin.marks,size=30,overlap=10,around=5)
colin.map <- map.overlapping.batches(colin.marks,size=size.colin,overlap=10,phase.cores=4)
print(paste0("Log-likelihood revised map: ",reord.map$Map$seq.like))
print(paste0("Log-likelihood collinear map: ",colin.map$Map$seq.like))
write.map(colin.map$Map,paste0("map_",LG,"_colin.txt"))
save.image(paste0("map_",LG,"_colin.RData"))