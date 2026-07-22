library(BatchMap)

args <- commandArgs(trailingOnly=TRUE)
ncore <- as.numeric(args[1])
outdir=args[2]
LG <- as.numeric(args[3])
iteration <- as.numeric(args[4])

load("onemap_functions_for_batchmap.RData")
load("LGs_created_manbin_clean.RData")

print(paste0("[M]: Creating map for LG ",LG,", iteration ",iteration))


if (ncore >= 10) {
	reccore=10
} else {
	stop("[E]: Not enough cores supplied. Need at least 10.")
}

max.dist=kosambi(0.2)
LG_cur=LG_list_clean[[LG]]

rec=record.parallel(LG_cur,times=20,cores=reccore)
if (tail(rec$seq.num,n=1) < head(rec$seq.num,n=1)) {
    #rec built the order in reverse
    rev=make.seq(twopt_table,rev(rec$seq.num))
    rec=rev
}

size=pick.batch.sizes(rec,size=30,overlap=10,around=5)
rip.map=map.overlapping.batches(
	input.seq=rec,
	phase.cores=2,
	overlap=10,
	size=size,
	fun.order=ripple.ord,
	ripple.cores=round(ncore/2),
	ws=10,
	verbosity=c("batch","order"),
	optimize="likelihood",
	max.dist=max.dist,
	min.tries=3,
    max.tries=10)

out <- paste("map",LG,iteration,sep="_")
write.map(rip.map$Map,file=file.path(paste0("map_LG",LG,"_iteration",iteration,".txt"))
write.map(rip.map$Map,file=file.path(paste0("map_LG",LG,"_iteration",iteration,".txt"))
rip.map$Map$data.name <- outcross_clean
rip.map$Map$twopt <- twopt_table
png(file.path(outdir,paste0("LG",LG,"_iteration",iteration,"_rfheatmap",".png")),
    width=960,height=960)
rf_graph_table(input.seq=rip.map$Map, display=FALSE, 
    lab.xy=c(paste0("Marker (n=",length(rip.map$Map$seq.num),")"),
        paste0("Marker (n=",length(rip.map$Map$seq.num),")")),
    mrk.axis="none",base.size=22)
dev.off()
rip.map$Map$data.name <- "outcross_clean"
rip.map$Map$twopt <- "twopt_table"
save.image(file=file.path(outdir,paste0(out,".RData")))



