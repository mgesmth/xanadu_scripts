library(BatchMap)

args <- commandArgs(trailingOnly=TRUE)
ncore <- as.numeric(args[1])
outdir=args[2]
LG <- args[3]
iteration <- as.numeric(args[4])

load("onemap_functions_for_batchmap.RData")
load("LGs_created_maxrf0.2_LOD12_cleaned.RData")

create_sampled_map <- function(LG,avail_cores) {
	if (avail_cores >= 10) {
		reccore=10
	} else {
		stop("[E]: Not enough cores supplied. Need at least 10.")
	}

	max.dist=kosambi(0.25)
	LG_cur=LG_list_clean[[LG]]

	samp=make.seq(twopt_table,sample(
		LG_cur$seq.num,
		size=100,
		replace=F))
	rec=record.parallel(samp,times=30,cores=reccore)
	if tail(rec$seq.num,n=1) < head(rec$seq.num,n=1) {
		#rec built the order in reverse
		rev=make.seq(twopt_table,rev(rec$seq.num))
		rec=rev
	}

	size=pick.batch.sizes(rec,size=50,overlap=30,around=10)
	rec.map=map.overlapping.batches(
		input.seq=rec,
		phase.cores=2,
		overlap=30,
		size=size)
	rip.map=map.overlapping.batches(
		input.seq=rec,
		phase.cores=2,
		overlap=30,
		size=size,
		fun.order=ripple.ord,
		ripple.cores=round(avail_cores/2),
		ws=10,
		verbosity=c("batch","order"),
		optimize="likelihood",
		max.dist=max.dist,
		min.tries=3,
		max.tries=10)

	list=list()
	list[["map"]]=rip.map
	return(list)

}

print(paste0("[M]: Creating subsampled map for ",LG,", iteration ",iteration))

out <- paste(LG,iteration,sep="_")
assign(paste0(out,"_obj"), create_sampled_map(LG,ncore))
save(paste0(out,"_obj"),file.path(outdir,paste0(out,".RData")))



