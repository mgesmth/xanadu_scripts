library(tidyverse)
library(ggplot2)

setwd("~/Documents/annotation")

introns <- read_tsv("collapsed_introns_filt.s.bed", col_names = F)
colnames(introns) <- c("scaffold","start","end","geneid")

#check to make sure no end coordinate is sooner than start coordinate
for (i in 1:nrow(introns)){
  start=introns[i,2]
  end=introns[i,3]
  if (start > end) {
    print("Start coordinate larger than end coordinate")
    print(introns[i,])
    break
  }
}
##true

#get length of each intron
introns$len <- introns$end-introns$start
introns <- introns[,c(1,2,3,5,4)]

#get a list of geneids
loci <- introns$geneid %>%
  unique()

#define a function to get the sum of all introns for a locus
get_intron_space_by_locus <- function(geneid) {
  sum <- sum(introns[introns$geneid == geneid,4])
  return(sum)
}

#apply that function over the loci object
sums <- c()
for (i in 1:length(loci)){
  sums <- append(sums, get_intron_space_by_locus(loci[i]))
}
rm(i)

intron_len_per_locus <- data.frame(locus=loci, intron_len=sums)

##genes
genes <- read_tsv("gene_coordinates_filt.s.bed", col_names=F)
colnames(genes) <- c("scaffold","start","end","geneid")
genes$len <- genes$end-genes$start
genes <- genes[,c(1,2,3,5,4)]

#gene list is longer than intron list. I suspect this is because of monoexonic genes.
##check to make sure, meg!
monos <- setdiff(genes$geneid,loci)
mono_df <- data.frame(locus=monos,intron_len=rep(0,length(monos)))
intron_len_per_locus <- rbind(intron_len_per_locus,mono_df)


#sort the intron df

#assign an index to the genes order of loci (the correct order)
locus_index <- list()
for (i in 1:nrow(genes)){
  locus <- as.character(genes[i,5])
  locus_index[[locus]]=i
}

#identify the index number of the introns order of loci
current_intron_order <- c()
for (i in 1:nrow(intron_len_per_locus)){
  locus <- as.character(intron_len_per_locus[i,1])
  index <- locus_index[[locus]]
  current_intron_order <- append(current_intron_order, index)
}

intron_len_per_locus$index <- current_intron_order

intron_len_per_locus_sorted <- intron_len_per_locus[order(intron_len_per_locus$index),]
intron_len_per_locus_sorted <- intron_len_per_locus_sorted[,-3]                      

#add intron information to genes
genes$intron_len <- intron_len_per_locus_sorted$intron_len
