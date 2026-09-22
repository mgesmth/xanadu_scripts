library(BatchMap)


args <- commandArgs(trailingOnly=TRUE)
LG=args[1]
num_subsample=as.numeric(args[2])
totcore=as.numeric(args[3])

if (totcore >= 20) {
	reccore=20
} else if (totcore >= 10 && totcore < 20) {
	reccore=10
} else if (totcore < 10 && totcore >= 5) {
	reccore=5
} else {
	recore=2
}

load("LGs_created_maxrf0.25_LOD10_cleaned.RData")

LG_all=LG_list_clean[[LG]]
genomic_seq.num <- LG_all$seq.num

for (i in 1:num_subsample) {
	LG_sub=make.seq(twopt_table,sample(LG_all$seq.num,n=100,replace=FALSE))
	size=pick.batch.sizes(LG_sub,size=50,overlap=30,around=10)
	record=record.parallel(LG_sub,times=20,cores=reccore)
	ripcore=round(totcore/2)
	ripple_map=map.overlapping.batches(record,
		size=size,
		overlap=30,
		fun.order=ripple.ord,
		phase.cores=2,
		ripple.cores=ripcore,
		ws=10,
		max.dist=25,
		max.tries=10,
		min.tries=3,
		optimize="likelihood",
		verbosity="batch",
		method="one")
	order=ripple_map$Map$seq.num

}

