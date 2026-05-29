library(tidyverse)
library(ggplot2)

setwd("~/Documents/Documents - Meg’s MacBook Pro/PhD/last_structural_variants/")

interval=1e7

genome <- read_tsv("genome_12.txt",col_names = F)
colnames(genome) <- c("chr","len")

introns <- read_tsv("introns.tsv", col_names = F)
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
genes <- read_tsv("genes.tsv", col_names=F)
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
for (i in 1:12){
  chrs <- append(chrs,paste0("chr",i))
}
gene_num_per_chr <- data.frame(chr=c(),count=c())
for (chr in chrs){
  gene_num_per_chr[as.integer(sub("chr","",chr)),1] <- chr
  gene_num_per_chr[as.integer(sub("chr","",chr)),2] <- nrow(genes[genes$chr == chr,])
}
colnames(gene_num_per_chr) <- c("chr","count")
gene_num_per_chr$len_mb <- genome$len/1e6
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
  chr_len=genome$len[i]
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
allele_summary <- read_tsv("sv_allele_summary_justint_unbroken_13.tsv",col_names = F)
colnames(allele_summary) <- c("chr","start","end","alt_geno",
                              "prim_len","alt_len","inv")
allele_summary$chr <- gsub("scaffold_","chr",allele_summary$chr)
allele_summary <- filter(allele_summary, chr %in% chrs)
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

repeats <- read_tsv("repeats.tsv", col_names = F)
colnames(repeats) <- c("chr","start","end","family")
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

ltrs <- grep("LTR",unique(repeats$family),value=T)
ltr <- repeats %>%
  filter(family %in% ltrs) %>%
  as.data.frame()
sum_ltr <- c()
for (i in 1:nrow(windows)){
  chr=windows$chr[i]
  win_start=windows$win_start[i]*1e6
  win_end=windows$win_end[i]*1e6
  sum <- prop_feature_inwindow(ltr,chr,win_start,win_end)
  sum_ltr <- append(sum_ltr,sum)
}
rm(i,chr,win_start,win_end,sum)
windows$ltr_prop <- sum_ltr

ggplot(data=windows,aes(x=win_start*1e6,y=repeat_prop))+
  geom_line()+
  labs(x="Position (Mb)",y="LTR-RT Density")+
  facet_wrap(~chr,scales = "free_x")+
  theme_bw()
  

#add repeats, turn window start/end to Mb scale, and standardize data
windows$repeat_prop <- sum_repeats
windows$win_start <- windows$win_start/1e6
windows$win_end <- windows$win_end/1e6
windows$gene_scaled <- scale(windows$prop_gene)
windows$sv_scaled <- scale(windows$count_sv)
windows$repeat_scaled <- scale(windows$repeat_prop)
windows$chr <- factor(windows$chr, levels=chrs)

##gypsy element plots----
gypsy <- read_tsv("gypsy_coordinates.tsv", col_names = F)
colnames(gypsy) <- c("chr","start","end")
gypsy$len <- gypsy$end-gypsy$start
sum_gypsy <- c()
for (i in 1:nrow(windows)){
  chr=windows$chr[i]
  win_start=windows$win_start[i]*1e6
  win_end=windows$win_end[i]*1e6
  sum <- prop_feature_inwindow(gypsy,chr,win_start,win_end)
  sum_gypsy <- append(sum_gypsy,sum)
}
rm(i,chr,win_start,win_end,sum)

windows$gypsy_prop <- sum_gypsy

gypsyplots <- list()
for (i in 1:13){
  gypsyplots[[i]] <- ggplot(data=windows[windows$chr == paste0("chr",i),],
                          aes(x=win_start,y=gypsy_prop))+
    geom_line()
  gypsyplots[[i]]
}

windows$chr <- factor(windows$chr,levels = chrs)

#Ideogram Plots----

##Genes----

windows %>%
  pivot_longer(windows[,c()])
ggplot(data=windows,aes(x=win_start,y=prop_gene))+
  geom_line(color="steelblue")+
  facet_wrap(~chr,scales="free_x",ncol=6)+
  labs(x="Position (Mb)",y="Gene Density")+
  theme_bw(base_size=16)


gene_ideograms <- list()

for (i in 1:13){
  chrom=paste0("chr",i)
  gene_ideograms[[i]] <- ggplot(data=filter(windows,chr==chrom),aes(x=win_start,y=prop_gene))+
    geom_point(size=0.5,color="grey")+geom_line()+
    labs(x="",y="")+
    theme_minimal(base_size = 12)+
    ylim(0,0.022)
  #print(gene_ideograms[[i]])
}
rm(i,chrom)

ggplot(data=windows,aes(x=win_start,y=prop_gene))+
  geom_point(size=0.5,color="grey")+geom_line()+
  labs(x="Position (Mb)",y="Exon Density")+
  facet_wrap(~chr,scales = "free_x",ncol=6)+
  theme_bw()

ggarrange(gene_ideograms[[1]],gene_ideograms[[2]],gene_ideograms[[3]],
          gene_ideograms[[4]],gene_ideograms[[5]],gene_ideograms[[6]],
          gene_ideograms[[7]],gene_ideograms[[8]],gene_ideograms[[9]],
          gene_ideograms[[10]],gene_ideograms[[11]],gene_ideograms[[12]],
          gene_ideograms[[13]])

##SVs----
sv_ideograms <- list()

for (i in 1:13){
  chrom=paste0("chr",i)
  sv_ideograms[[i]] <- ggplot(data=filter(windows,chr==chrom),aes(x=win_start,y=count_sv))+
    geom_point(size=0.5,color="grey")+geom_line()+
    labs(x="",y="")+
    theme_minimal(base_size = 12)+
    ylim(0,900)
  #print(sv_ideograms[[i]])
}
rm(i,chrom)

ggarrange(sv_ideograms[[1]],sv_ideograms[[2]],sv_ideograms[[3]],
          sv_ideograms[[4]],sv_ideograms[[5]],sv_ideograms[[6]],
          sv_ideograms[[7]],sv_ideograms[[8]],sv_ideograms[[9]],
          sv_ideograms[[10]],sv_ideograms[[11]],sv_ideograms[[12]],
          sv_ideograms[[13]])

##Repeats----

repeat_ideograms <- list()

for (i in 1:13){
  repeat_ideograms[[i]] <- ggplot(data=filter(windows,chr==paste0("chr",i)),
                                  aes(x=win_start,y=repeat_prop))+
    geom_point(size=0.5,color="grey")+geom_line()+
    labs(x="",y="")+
    theme_minimal(base_size = 12)+
    ylim(0.46,0.79)
  print(repeat_ideograms[[i]])
}
rm(i)

windows_6 <- windows %>%
  filter(chr %in% head(chrs,6))%>%
  as.data.frame()
windows_12 <- windows %>%
  filter(chr %in% tail(chrs,6))%>%
  as.data.frame()

ggplot(data=windows,aes(x=win_start,y=repeat_prop))+
  geom_point(size=0.5,color="grey")+geom_line()+
  labs(x="Position (Mb)",y="Repeat Density")+
  facet_wrap(~chr,scales="free_x",ncol=6)+
  theme_bw(base_size=14)

#ideograms: all three variables for four chrs, two with weak relationships, two with strong relationships
ggarrange(nrow=3,ncol=4,gene_ideograms[[1]]+ggtitle("chr1")+
            theme(plot.title=element_text(face="bold",hjust=0.5))+ylab("Gene Density"),
          gene_ideograms[[2]]+ggtitle("chr2")+theme(plot.title=element_text(face="bold",hjust=0.5)),
          gene_ideograms[[9]]+ggtitle("chr9")+theme(plot.title=element_text(face="bold",hjust=0.5)),
          gene_ideograms[[10]]+ggtitle("chr10")+theme(plot.title=element_text(face="bold",hjust=0.5)),
          sv_ideograms[[1]]+ylab("SV Density"),
          sv_ideograms[[2]],sv_ideograms[[9]],sv_ideograms[[10]],
          repeat_ideograms[[1]]+xlab("Position (Mb)")+ylab("Repeat Density"),
          repeat_ideograms[[2]]+xlab("Position (Mb)"),
          repeat_ideograms[[9]]+xlab("Position (Mb)"),
          repeat_ideograms[[10]]+xlab("Position (Mb)"))

windows %>%
  pivot_longer(gene_scaled:repeat_scaled,names_to="feature",values_to="metric") %>%
  ggplot(aes(x=win_start,y=metric,colour=feature))+
  geom_line()+
  labs(x="Position (Mb)",y="Density (std)")+
  facet_wrap(~chr,ncol=6,scales="free_x")

ggplot(data=windows_transform[windows_transform$chr == "chr2",],aes(x=win_start,y=metric,color=feature))+
  geom_density()

ggplot(data=windows[windows$chr == "chr1",], aes(x=repeat_prop))+
  geom_density()

#Partial Regression----

part_cor <- pcor(windows[,c(4,6)], method = "kendall")

cloud_sg <- ggplot(data=windows, aes(x=prop_gene,y=count_sv))+
  geom_point(shape=21,fill=alpha("seagreen2",0.4),colour=alpha("seagreen",0.6))+
  theme_light(base_size=14)+
  labs(x="Gene Density",y="SV Density",title="SV/Gene")+
  theme(plot.title=element_text(hjust=0.5,face="bold"))+
  annotate(geom="text",x=0.023,y=90,
           label=paste0("R = ",format(
             part_cor$estimate['prop_gene','count_sv'],
             digits=3)),hjust=1)+
  annotate(geom="text",x=0.023,y=30,
           label=paste0("p = ",format(
             part_cor$p.value['prop_gene','count_sv'],
             digits=3)),hjust=1)
cloud_gr <- ggplot(data=windows, aes(x=prop_gene,y=repeat_prop))+
  geom_point(shape=21,fill=alpha("darkorange",0.3),colour=alpha("darkorange3",0.5))+
  theme_light(base_size=14)+
  labs(x="Gene Density",y="Repeat Density",
       title="Repeat/Gene")+
  theme(plot.title=element_text(hjust=0.5,face="bold"))+
  annotate(geom="text",x=0.023,y=0.77,
           label=paste0("R = ",format(
             part_cor$estimate['prop_gene','repeat_prop'],
             digits=3)),hjust=1)+
  annotate(geom="text",x=0.023,y=0.75,
           label=paste0("p = ",format(
             part_cor$p.value['prop_gene','repeat_prop'],
             digits=3)),hjust=1)
cloud_sr <- ggplot(data=windows, aes(x=repeat_prop,y=count_sv))+
  geom_point(shape=21,fill=alpha("darkorchid1",0.3),color=alpha("darkorchid4",0.5))+
  theme_light(base_size=14)+
  labs(x="Repeat Density",y="SV Density",title = "SV/Repeat")+
  theme(plot.title=element_text(hjust=0.5,face="bold"))+
  annotate(geom="text",x=0.8,y=820,
           label=paste0("R = ",format(
             part_cor$estimate['count_sv','repeat_prop'],
             digits=3)),hjust=1)+
  annotate(geom="text",x=0.8,y=760,
           label=paste0("p = ",format(
             part_cor$p.value['count_sv','repeat_prop'],
             digits=3)),hjust=1)

ggarrange(cloud_sg,cloud_sr,cloud_gr,ncol=3)

gene_dense_windows <- data.frame(chr=c(),win_start=c(),win_end=c(),prop_gene=c())
for (i in 1:nrow(windows)){
  if (windows$prop_gene[i] > 0.01) {
    gene_dense_windows <- rbind(gene_dense_windows,data.frame(
      chr=windows$chr[i],
      win_start=windows$win_start[i],
      win_end=windows$win_end[i],
      prop_gene=windows$prop_gene[i]
    ))
  }
}

unique(gene_dense_windows$chr)

gene_poor_windows <- data.frame(chr=c(),win_start=c(),win_end=c(),prop_gene=c())
for (i in 1:nrow(windows)){
  if (windows$prop_gene[i] < 0.01) {
    gene_poor_windows <- rbind(gene_poor_windows,data.frame(
      chr=windows$chr[i],
      win_start=windows$win_start[i],
      win_end=windows$win_end[i],
      prop_gene=windows$prop_gene[i]
    ))
  }
}

unique(gene_poor_windows$chr)

##chr-by-chr correlations---

##Adjusted alpha for 12 comparisons
a <- 0.05
k <- 13
adjusted_p <- 1-(1-a)^(1/k)

ps <- list()
bychr_part_cor <- data.frame(chr=c(),
                             #p_gene_sv=c(),
                             #slope_gene_sv=c(),
                             p_gene_repeat=c(),
                             slope_gene_repeat=c())
                             #p_repeat_sv=c(),
                             #slope_repeat_sv=c())
for (i in 1:12){
  df_f <- filter(windows,chr==paste0("chr",i))
  #pc <- pcor(df_f[,7:9], method = "kendall")
  pc <- pcor(df_f[,c(7,8)], method = "kendall")
  ps[[i]] <- pc
  df <- data.frame(chr=i,
                   #p_gene_sv=pc$p.value['gene_scaled','sv_scaled'],
                   #slope_gene_sv=pc$estimate['gene_scaled','sv_scaled'],
                   p_gene_repeat=pc$p.value['gene_scaled','repeat_scaled'],
                   slope_gene_repeat=pc$estimate['gene_scaled','repeat_scaled'])
                   #p_repeat_sv=pc$p.value['repeat_scaled','sv_scaled'],
                   #slope_repeat_sv=pc$estimate['repeat_scaled','sv_scaled'])
  bychr_part_cor <- rbind(bychr_part_cor,df)
}
rm(i,df_f,pc,df)


chr_2_sg <- windows_transform %>%
  filter(feature != "repeat_scaled") %>%
  filter(chr == "chr2") %>%
  ggplot(aes(x=win_start,y=metric,colour=feature))+
  geom_line(linewidth=1)+
  scale_colour_manual(labels=c("Gene","SV"),values=c("darkgoldenrod2","deepskyblue1"))+
  theme_light(base_size=16)+
  labs(x="",y="Density (std.)",colour="Feature",title="Chromosome 2")+
  theme(plot.title=element_text(hjust=0.5,face="bold"))
chr_2_sg

chr_2_sr <- windows_transform %>%
  filter(feature != "gene_scaled") %>%
  filter(chr == "chr2") %>%
  ggplot(aes(x=win_start,y=metric,colour=feature))+
  geom_line(linewidth=1)+
  scale_colour_manual(labels=c("Repeat","SV"),values=c("firebrick1","deepskyblue1"))+
  theme_light(base_size=16)+
  labs(x="",y="Density (std.)",colour="Feature")
chr_2_sr

chr_2_gr <- windows_transform %>%
  filter(feature != "sv_scaled") %>%
  filter(chr == "chr2") %>%
  ggplot(aes(x=win_start,y=metric,colour=feature))+
  geom_line(linewidth=1)+
  scale_colour_manual(labels=c("Gene","Repeat"),values=c("darkgoldenrod1","firebrick1"))+
  theme_light(base_size=16)+
  labs(x="Position (Mb)",y="Density (std.)",colour="Feature")
chr_2_gr

ggarrange(chr_2_sg,chr_2_sr,chr_2_gr,ncol=1)

chr_9_sg <- windows_transform %>%
  filter(feature != "repeat_scaled") %>%
  filter(chr == "chr9") %>%
  ggplot(aes(x=win_start,y=metric,colour=feature))+
  geom_line(linewidth=1)+
  scale_colour_manual(labels=c("Gene","SV"),values=c("darkgoldenrod2","deepskyblue1"))+
  theme_light(base_size=16)+
  labs(x="",y="Density (std.)",colour="Feature",title="Chromosome 9")+
  theme(plot.title=element_text(hjust=0.5,face="bold"))
chr_9_sg

chr_9_sr <- windows_transform %>%
  filter(feature != "gene_scaled") %>%
  filter(chr == "chr9") %>%
  ggplot(aes(x=win_start,y=metric,colour=feature))+
  geom_line(linewidth=1)+
  scale_colour_manual(labels=c("Repeat","SV"),values=c("firebrick1","deepskyblue2"))+
  theme_light(base_size=16)+
  labs(x="",y="Density (std.)",colour="Feature")
chr_9_sr

chr_9_gr <- windows_transform %>%
  filter(feature != "sv_scaled") %>%
  filter(chr == "chr9") %>%
  ggplot(aes(x=win_start,y=metric,colour=feature))+
  geom_line(linewidth=1)+
  scale_colour_manual(labels=c("Gene","Repeat"),values=c("darkgoldenrod2","firebrick1"))+
  theme_light(base_size=16)+
  labs(x="Position (Mb)",y="Density (std.)",colour="Feature")
chr_9_gr

ggarrange(chr_9_sg,chr_9_sr,chr_9_gr,ncol=1)

chr_8_sg <- windows_transform %>%
  filter(feature != "repeat_scaled") %>%
  filter(chr == "chr8") %>%
  ggplot(aes(x=win_start,y=metric,colour=feature))+
  geom_line(linewidth=1)+
  scale_colour_manual(labels=c("Gene","SV"),values=c("darkgoldenrod2","deepskyblue1"))+
  theme_light(base_size=16)+
  labs(x="",y="Density (std.)",colour="Feature",title="Chromosome 8")+
  theme(plot.title=element_text(hjust=0.5,face="bold"))
chr_8_sg

chr_8_sr <- windows_transform %>%
  filter(feature != "gene_scaled") %>%
  filter(chr == "chr8") %>%
  ggplot(aes(x=win_start,y=metric,colour=feature))+
  geom_line(linewidth=1)+
  scale_colour_manual(labels=c("Repeat","SV"),values=c("firebrick1","deepskyblue2"))+
  theme_light(base_size=16)+
  labs(x="",y="Density (std.)",colour="Feature")
chr_8_sr

chr_8_gr <- windows_transform %>%
  filter(feature != "sv_scaled") %>%
  filter(chr == "chr8") %>%
  ggplot(aes(x=win_start,y=metric,colour=feature))+
  geom_line(linewidth=1)+
  scale_colour_manual(labels=c("Gene","Repeat"),values=c("darkgoldenrod2","firebrick1"))+
  theme_light(base_size=16)+
  labs(x="Position (Mb)",y="Density (std.)",colour="Feature")
chr_8_gr

ggarrange(chr_8_sg,chr_8_sr,chr_8_gr, ncol=1)

#

#get a dataframe of the end of the last window for each chr
#this will be added to the end o
max_win <- data.frame(chr=c(),last_win_end=c())
for (i in 1:13){
  chrom <- paste0("chr",i)
  x <- windows %>%
    filter(chr == chrom) %>%
    select(win_end) %>%
    max()
  max_win <- rbind(max_win,data.frame(chr=chrom,last_win_end=x))
}
rm(i,x,chrom)

max_win$sum <- cumsum(max_win$last_win_end)

win_start_new=c()
win_end_new=c()
for (i in 1:13){
  if (i == 1) {
    x=0
  } else {
    x=max_win[i-1,3]
  }
  win_start <- windows[windows$chr == paste0("chr",i),2] 
  win_start_new <- append(win_start_new,(win_start+x))
  win_end <- windows[windows$chr == paste0("chr",i),3] 
  win_end_new <- append(win_end_new,(win_end+x))
}
rm(i,x,win_start,win_end)

windows_continuous <- windows[,c(-2,-3)]
windows_continuous$win_start <- win_start_new
windows_continuous$win_end <- win_end_new
windows_continuous <- windows_continuous[,c(1,8,9,2,3,4,5,6,7)]

for_chr_boxes <- data.frame(chr=c(),start=c(),end=c())
for (i in 1:13){
  if (i == 1){
    start=1
    end=max_win[i,3]
  } else {
    start=((max_win[i-1,3]*1e6)+1)/1e6
    end=max_win[i,3]
  }
  for_chr_boxes <- rbind(for_chr_boxes,
                         data.frame(chr=paste0("chr",i),
                                    start=start,
                                    end=end))
}
rm(i,start,end)

ggplot(data=windows_continuous,aes(x=win_start,y=count_sv))+
  geom_line()+
  scale_x_continuous(
    name="Chromosome",
    breaks=c(for_chr_boxes$end),
    labels = 1:13
  )



ggplot(data=windows,aes(x=win_start,y=prop_gene))+
  geom_line()+
  facet_wrap(~chr,scales="free_x")


