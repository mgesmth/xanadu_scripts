library(tidyverse)

dir.create("map_plots")

LGs <- c()
for (i in 1:13){
  LGs <- append(LGs,paste0("LG_",i))
}

marey_maps <- list()
collinearity_plots <- list()
full_map <- data.frame(chr=c(),pos=c(),cM=c(),genetic_rank=c(),genomic_rank=c())
for (LG in LGs){
  nice_lg=paste0("Linkage Group ",strsplit(LG,"_")[[1]][2])
  outdir <- paste(LG,"maps",sep="_")
  rec_map <- read_tsv(file.path(outdir,"recomb_map.tsv"),col_names = F)
  rec_map <- rec_map[,-1]
  colnames(rec_map) <- c("x","cM")
  rec_map <- separate_wider_delim(rec_map,cols="x",names=c("chr","pos"),delim="_")
  rec_map$pos <- as.numeric(rec_map$pos)
  chrom=unique(rec_map$chr)
  marey_maps[[LG]] <- ggplot(rec_map,aes(x=pos/1e6,y=cM))+
    geom_point()+
    labs(title=paste0(nice_lg," (",chrom,")"),y="Genetic Distance (cM)",x="Genomic Distance (Mb)")+
    theme_bw(base_size=14)+
    theme(plot.title = element_text(hjust=0.5,face="bold"))
  png(filename=file.path("map_plots",paste(LG,"marey.png",sep="_")),width=656,height=423)
  ggplot(rec_map,aes(x=pos/1e6,y=cM))+
    geom_point()+
    labs(title=paste0(nice_lg," (",chrom,")"),y="Genetic Distance (cM)",x="Genomic Distance (Mb)")+
    theme_bw(base_size=14)+
    theme(plot.title = element_text(hjust=0.5,face="bold"))
  dev.off()
  
  #collinearity plot
  
  gen_map <- read_tsv(file.path(outdir,"genomic_map.tsv"),col_names = F)
  gen_map <- gen_map[,-1]
  colnames(gen_map) <- c("x","cM")
  gen_map <- separate_wider_delim(gen_map,cols="x",names=c("chr","pos"),delim="_")
  gen_map$pos <- as.numeric(gen_map$pos)
  
  rec_map$genetic_rank=seq(1,nrow(rec_map))
  gen_map$genomic_rank=seq(1,nrow(gen_map))
  
  x=c()
  for (i in 1:nrow(rec_map)){
    pos=rec_map$pos[i]
    add=gen_map[gen_map$pos == pos,4][[1]]
    x=append(x,add)
  }
  
  rec_map$genomic_rank <- x
  collinearity_plots[[LG]] <- ggplot(data=rec_map,aes(x=genetic_rank,y=genomic_rank))+
    geom_point()+
    labs(title=paste0(nice_lg," (",chrom,")"),
         x="Genetic Rank",y="Genomic Rank")+
    theme_bw(base_size=14)+
    theme(plot.title=element_text(hjust=0.5,face="bold"))
  png(filename = file.path("map_plots",paste(LG,"collinearity.png",sep="_")),
      width=656,height=423)
  ggplot(data=rec_map,aes(x=genetic_rank,y=genomic_rank))+
    geom_point()+
    labs(title=paste0(nice_lg," (",chrom,")"),
         x="Genetic Rank",y="Genomic Rank")+
    theme_bw(base_size=14)+
    theme(plot.title=element_text(hjust=0.5,face="bold"))
  dev.off()
  
  #append Lg map to full map
  
  full_map <- rbind(full_map,rec_map)  
  
  
}

save.image(file=file.path("map_plots","plots.RData"))