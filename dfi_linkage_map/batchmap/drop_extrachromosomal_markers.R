library(BatchMap)

load("LGs_created_maxrf0.25_LOD10")

LG_list_clean <- list()

#LG_1 -> chromosome 1
LG_cur=LG_list[["LG_1"]]
#last 9 markers
remove=tail(LG_cur$seq.num,n=9)
LG_list_clean[["LG_1"]] <- drop.marker(LG_cur,remove)

#LG_1 -> chromosome 4
LG_cur=LG_list[["LG_2"]]
#first 4 markers, last marker
remove=head(LG_cur$seq.num,n=4)
remove=append(remove,tail(LG_cur$seq.num,n=1))
LG_list_clean[["LG_2"]] <- drop.marker(LG_cur,remove)

#LG_3 -> chromosome 2
LG_cur=LG_list[["LG_3"]]
#last 4 markers
remove=tail(LG_cur$seq.num,n=4)
LG_list_clean[["LG_3"]] <- drop.marker(LG_cur,remove)

#LG_4 -> chromosome 11
LG_cur=LG_list[["LG_4"]]
#markers 2 and 3 in the sequence
remove=tail(head(LG_cur$seq.num,n=3),n=2)
LG_list_clean[["LG_4"]] <- drop.marker(LG_cur,remove)

#LG_5 -> chromosome 5
LG_cur=LG_list[["LG_5"]]
#first 3, last 2
remove=head(LG_cur$seq.num,n=3)
remove=append(remove,tail(LG_cur$seq.num,n=2))
LG_list_clean[["LG_5"]] <- drop.marker(LG_cur,remove)

#LG_6 is a two-marker LG
#LG_7 -> chromosome 7
LG_cur=LG_list[["LG_7"]]
#first 5, last 2
remove=head(LG_cur$seq.num,n=5)
remove=append(remove,tail(LG_cur$seq.num,n=2))
LG_list_clean[["LG_7"]] <- drop.marker(LG_cur,remove)

#LG_8 -> chromosome 3
LG_cur=LG_list[["LG_8"]]
#first 2, last 11
remove=head(LG_cur$seq.num,n=2)
remove=append(remove,tail(LG_cur$seq.num,n=11))
LG_list_clean[["LG_8"]] <- drop.marker(LG_cur,remove)
LG_list_clean[["LG_8"]]

#LG_9 -> chromosome 6
LG_cur=LG_list[["LG_9"]]
#first 4, last 5
remove=head(LG_cur$seq.num,n=4)
remove=append(remove,tail(LG_cur$seq.num,n=5))
LG_list_clean[["LG_9"]] <- drop.marker(LG_cur,remove)
LG_list_clean[["LG_9"]]

#LG_10 -> chromosome 13
LG_cur=LG_list[["LG_10"]]
#last 3
remove=tail(LG_cur$seq.num,n=3)
LG_list_clean[["LG_10"]] <- drop.marker(LG_cur,remove)
LG_list_clean[["LG_10"]]

#LG_11 -> chromosome 9
LG_cur=LG_list[["LG_11"]]
#markers 1,3 and last
remove=head(LG_cur$seq.num,n=1)
remove=append(remove,LG_cur$seq.num[3])
remove=append(remove, tail(LG_cur$seq.num,n=1))
LG_list_clean[["LG_11"]] <- drop.marker(LG_cur,remove)
LG_list_clean[["LG_11"]]

#LG_12 -> chromosome 12
LG_cur=LG_list[["LG_12"]]
#last 2
remove=tail(LG_cur$seq.num,n=2)
LG_list_clean[["LG_12"]] <- drop.marker(LG_cur,remove)
LG_list_clean[["LG_12"]]

#LG_13 is a two-marker LG
#LG_14 -> chromosome 10
LG_cur=LG_list[["LG_14"]]
#markers2-5,last 2
remove=LG_cur$seq.num[2:5]
remove=append(remove,tail(LG_cur$seq.num,n=2))
LG_list_clean[["LG_14"]] <- drop.marker(LG_cur,remove)
LG_list_clean[["LG_14"]]

#LG_15 -> chromosome 8
LG_cur=LG_list[["LG_15"]]
#first,last 2
remove=c(LG_cur$seq.num[1],tail(LG_cur$seq.num,n=2))
LG_list_clean[["LG_15"]] <- drop.marker(LG_cur,remove)
LG_list_clean[["LG_15"]]

save.image("LGs_created_maxrf0.25_LOD10_cleaned.RData")