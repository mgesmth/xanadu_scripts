library(tidyverse)

#creating this df, particularly because of the repeats, is memory intense and my laptop can't do it
#this is just the first part of sv_gene_density_annotated_wintrons.R

#expecting to find the following files:
####genome.txt - 13 chrs, with cols chr,start,end
####introns_merged.tsv - intron coordinates with gene id in column 4
####psme_glauca_ann_nopseudo_genecoord.tsv - gene coordinates, same format as prev.
####sv_allele_summary_unbroken_13.tsv - unbroken sv allele sum with just the major chrs
####repeats_shifted_coordinates_chr.tsv - repeat coordinates with family in column 4

args <- commandArgs(trailingOnly = TRUE)
wd=args[1]
interval=as.numeric(args[2])

setwd(wd)

genome <- read_tsv("genome.txt",col_names = T)

introns <- read_tsv("introns_merged.tsv", col_names = F)
colnames(introns) <- c("chr","start","end","geneid")

#check to make sure no end coordinate is sooner than start coordinate
for (i in 1:nrow(introns)){
  start=introns[i,2]
  end=introns[i,3]
  if (start > end) {
    print("Start coordinate larger than end coordinate")
    print(introns[i,])
    break
  }
  if (i == nrow(introns)) {
    print("All start coordinates are smaller than end coordinates.")
  }
}
rm(i,start,end)

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
genes <- read_tsv("psme_glauca_ann_nopseudo_genecoord.tsv", col_names=F)
colnames(genes) <- c("chr","start","end","geneid")
genes$len <- genes$end-genes$start
genes <- genes[,c(1,2,3,5,4)]

#gene list is longer than intron list. I suspect this is because of monoexonic genes.
##check to make sure, meg!
monos <- setdiff(genes$geneid,loci)
mono_df <- data.frame(locus=monos,intron_len=rep(0,length(monos)))
intron_len_per_locus <- rbind(intron_len_per_locus,mono_df)


#sort the intron df
#assign an index to the genes order of loci (the correct order)
intron_len_per_locus$order <- match(intron_len_per_locus$locus,genes$geneid)
intron_len_per_locus <- intron_len_per_locus[order(intron_len_per_locus$order),]

#add intron information to genes
genes$intron_len <- intron_len_per_locus$intron_len

genes$exon_len <- genes$len-genes$intron_len
genes <- genes[,c(1,2,3,4,6,7,5)]
genes$gene_len <- genes$len
genes <- genes[,c(1,2,3,8,5,6,7)]
genes$len <- genes$exon_len
genes <- genes[,c(1:5,8,7)]

chrs <- c()
for (i in 1:13){
  chrs <- append(chrs,paste0("chr",i))
}
gene_num_per_chr <- data.frame(chr=c(),count=c())
for (chr in chrs){
  gene_num_per_chr[as.integer(sub("chr","",chr)),1] <- chr
  gene_num_per_chr[as.integer(sub("chr","",chr)),2] <- nrow(genes[genes$chr == chr,])
}
colnames(gene_num_per_chr) <- c("chr","count")
gene_num_per_chr$len_mb <- genome$end/1e6
gene_num_per_chr$count_len <- gene_num_per_chr$count/gene_num_per_chr$len_mb

avg_feature_inwindow <- function(feature_df,chrom,win_start,win_end){
  lengths <- feature_df %>%
    filter(chr == chrom) %>%
    filter(start >= win_start) %>%
    filter(end < win_end)
  return(mean(as.vector(lengths$len)))
}

#filter for just the first 13 scaffolds
chrs <- c()
for (i in 1:12){
  chrs <- append(chrs,paste0("chr",i))
}
rm(i)
genes <- filter(genes,chr %in% chrs)

#create a windowed df

windows <- data.frame(chr=c(),win_start=c(),win_end=c())
for (i in 1:nrow(genome)){
  chr=genome$chr[i]
  chr_len=genome$end[i]
  win_start <- seq(1,chr_len,interval)
  win_end <- seq(1,chr_len,interval)+(interval-1)
  last=length(win_end)
  #if the last window passes the end of the chr, make it end early (at the chr end)
  if (win_end[last] > chr_len) {
    win_start <- win_start[-length(win_start)]
    win_end <- win_end[-length(win_end)]
    #win_end[last]=chr_len
  }
  windows <- rbind(windows,
                   data.frame(chr=rep(chr,length(win_start)),
                              win_start=win_start,
                              win_end=win_end))
}
rm(i,chr,chr_len,win_start,win_end,last)

#function to calculate proportion of window that a gene lives in
#uses the dataframe from above^/assumes it exists
prop_feature_inwindow <- function(feature_df,chrom,win_start,win_end){
  lengths <- feature_df %>%
    filter(chr == chrom) %>%
    filter(start >= win_start) %>%
    filter(end < win_end) 
  interval <- (win_end-win_start)+1
  return(sum(lengths$len)/interval)
}

#get the proportion of genic space for each window and add that to the windows df
prop_gene <- c()
for (i in 1:nrow(windows)){
  chrom=windows$chr[i]
  win_start=windows$win_start[i]
  win_end=windows$win_end[i]
  prop_gene <- append(prop_gene,
                      prop_feature_inwindow(genes,chrom,win_start,win_end))
}
windows$prop_gene <- prop_gene
rm(i,chrom,win_start,win_end)

#intron lengths

avg_intron <- c()
for (i in 1:nrow(windows)){
  chrom=windows$chr[i]
  win_start=(windows$win_start[i])
  win_end=(windows$win_end[i])
  avg <- avg_feature_inwindow(genes,chrom,win_start,win_end)
  avg_intron <- append(avg_intron, avg)
}
rm(i,win_start,win_end,avg,chrom)

windows$avg_intron_len <- avg_intron

#sv density----
allele_summary <- read_tsv("sv_allele_summary_unbroken_13.tsv",col_names = F)
colnames(allele_summary) <- c("chr","start","end","alt_geno",
                              "prim_len","alt_len","inv")
allele_summary$long=pmax(allele_summary$prim_len,allele_summary$alt_len)
allele_summary_1kb <- allele_summary[allele_summary$long >= 1000,]

#function to count variants by window
count_over_window <- function(feature_df,chrom,win_start,win_end){
  len <- feature_df %>%
    filter(chr == chrom) %>%
    filter(start >= win_start) %>%
    filter(end < win_end) %>%
    nrow()
  return(len)
}

#get SV counts per window 
count_sv <- c()
for (i in 1:nrow(windows)){
  chrom=windows$chr[i]
  win_start=windows$win_start[i]
  win_end=windows$win_end[i]
  count <- count_over_window(allele_summary_1kb,chrom,win_start,win_end)
  count_sv <- append(count_sv, count)
}
rm(i,win_start,win_end,count,chrom)

windows$count_sv <- count_sv

#Repeat Density----

repeats <- read_tsv("repeats_shifted_coordinates_chr.tsv", col_names =T)
repeats$len <- repeats$end-repeats$start

##note: this takes a while. Repeat list is long.
sum_repeats <- c()
for (i in 1:nrow(windows)){
  chr=windows$chr[i]
  win_start=windows$win_start[i]
  win_end=windows$win_end[i]
  sum <- prop_feature_inwindow(repeats,chr,win_start,win_end)
  sum_repeats <- append(sum_repeats,sum)
}
rm(i,chr,win_start,win_end,sum)

#add repeats, turn window start/end to Mb scale, and standardize data
windows$repeat_prop <- sum_repeats
windows$win_start <- windows$win_start/1e6
windows$win_end <- windows$win_end/1e6
#windows$gene_scaled <- scale(windows$prop_gene)
#windows$sv_scaled <- scale(windows$count_sv)
#windows$repeat_scaled <- scale(windows$repeat_prop)

write_tsv(windows,file="windows.tsv")
