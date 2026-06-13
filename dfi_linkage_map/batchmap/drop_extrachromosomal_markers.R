library(BatchMap)

load("LGs_created_maxrf0.25_LOD10.RData")

LG_list_clean <- list()

#LG_1 -> chromosome 1
LG_cur=LG_list[["LG_1"]]
#last 15 markers
remove=tail(LG_cur$seq.num,n=15)
LG_list_clean[["LG_1"]] <- drop.marker(LG_cur,remove)
LG_list_clean[["LG_1"]]

#LG_1 -> chromosome 11
LG_cur=LG_list[["LG_2"]]
#first 2 markers
remove=LG_cur$seq.num[1:2]
LG_list_clean[["LG_2"]] <- drop.marker(LG_cur,remove)
LG_list_clean[["LG_2"]]

#LG_3 -> chromosome 6
LG_cur=LG_list[["LG_6"]]
#first 4, last 3
remove=c(head(LG_cur$seq.num,n=4),tail(LG_cur$seq.num,n=3))
LG_list_clean[["LG_3"]] <- drop.marker(LG_cur,remove)
LG_list_clean[["LG_3"]]

#LG_4 -> chromosome 4
LG_cur=LG_list[["LG_4"]]
#first 5,last
remove=c(head(LG_cur$seq.num,n=5),tail(LG_cur$seq.num,n=1))
LG_list_clean[["LG_4"]] <- drop.marker(LG_cur,remove)
LG_list_clean[["LG_4"]]

#LG_5 -> chromosome 10
LG_cur=LG_list[["LG_5"]]
#first five markers, last
remove=c(head(LG_cur$seq.num,n=5),tail(LG_cur$seq.num,n=1))
LG_list_clean[["LG_5"]] <- drop.marker(LG_cur,remove)
LG_list_clean[["LG_5"]]

#LG_6 -> chromosome 5
LG_cur=LG_list[["LG_6"]]
#first 4, last 2
remove=c(head(LG_cur$seq.num,n=4),tail(LG_cur$seq.num,n=2))
LG_list_clean[["LG_6"]] <- drop.marker(LG_cur,remove)
LG_list_clean[["LG_6"]]

#LG_7 -> chromosome 2
LG_cur=LG_list[["LG_7"]]
#last 3
remove=tail(LG_cur$seq.num,n=3)
LG_list_clean[["LG_7"]] <- drop.marker(LG_cur,remove)
LG_list_clean[["LG_7"]]

#LG_8 -> chromosome 7
LG_cur=LG_list[["LG_8"]]
#first 4, last
remove=c(head(LG_cur$seq.num,n=4),tail(LG_cur$seq.num,n=1))
LG_list_clean[["LG_8"]] <- drop.marker(LG_cur,remove)
LG_list_clean[["LG_8"]]

#LG_9 -> chromosome 3
LG_cur=LG_list[["LG_9"]]
#first, last 11
remove=c(head(LG_cur$seq.num,n=1),tail(LG_cur$seq.num,n=11))
LG_list_clean[["LG_9"]] <- drop.marker(LG_cur,remove)
LG_list_clean[["LG_9"]]

#LG_10 -> chromosome 3
LG_cur=LG_list[["LG_10"]]
#first 1, last 8
remove=c(LG_cur$seq.num[1],tail(LG_cur$seq.num,n=8))
LG_list_clean[["LG_10"]] <- drop.marker(LG_cur,remove)
LG_list_clean[["LG_10"]]

#LG_11 -> chromosome 13
LG_cur=LG_list[["LG_11"]]
#firstand last 2
remove=c(LG_cur$seq.num[1],tail(LG_cur$seq.num,n=2))
LG_list_clean[["LG_11"]] <- drop.marker(LG_cur,remove)
LG_list_clean[["LG_11"]]

#LG_12 -> chromosome 9
LG_cur=LG_list[["LG_12"]]
#first 2, last 2
remove=c(head(LG_cur$seq.num, n=2),tail(LG_cur$seq.num,n=2))
LG_list_clean[["LG_12"]] <- drop.marker(LG_cur,remove)
LG_list_clean[["LG_12"]]

#LG_13 -> 2 mark LG
#LG_14 -> chromosome 8
LG_cur=LG_list[["LG_14"]]
#last 2
remove=tail(LG_cur$seq.num,n=2)
LG_list_clean[["LG_14"]] <- drop.marker(LG_cur,remove)
LG_list_clean[["LG_14"]]

save.image("LGs_created_maxrf0.15_LOD14_cleaned.RData")