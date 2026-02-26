library(tidyverse)
library(ggplot2)
library(ggpubr)
library(rstatix)

setwd("~/Documents/Documents - Meg’s MacBook Pro/PhD/justin_svs")
interval=2.5e7

#Genes----
#load in coordinates of genes and format
genes <- read_tsv("genes_coordinates_13.tsv",col_names = F)
colnames(genes) <- c("chr","start","end")
genes$chr <- gsub("scaffold_","chr",genes$chr)

#filter for just the first 13 scaffolds
chrs <- c()
for (i in 1:13){
  chrs <- append(chrs,paste0("chr",i))
}
rm(i)
genes <- filter(genes,chr %in% chrs)

#gene lengths
genes$len <- genes$end-genes$start

#create a windowed df
genome <- read_tsv("genome.txt",col_names = F)
colnames(genome) <- c("chr","start","end")
genome <- head(genome,n=13)
windows <- data.frame(chr=c(),win_start=c(),win_end=c())
for (i in 1:nrow(genome)){
  chr_num=genome$chr[i]
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
                   data.frame(chr=rep(paste0("chr",chr_num),length(win_start)),
                              win_start=win_start,
                              win_end=win_end))
}
rm(i,chr_num,chr_len,win_start,win_end,last)

#function to calculate proportion of window that a gene lives in
#uses the dataframe from above^/assumes it exists
prop_feature_inwindow <- function(feature_df,chrom,win_start,win_end){
  lengths <- feature_df %>%
    filter(chr == chrom) %>%
    filter(start >= win_start) %>%
    filter(end < win_end) %>%
    select(len)
  interval <- (win_end-win_start)+1
  return(sum(lengths)/interval)
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

#sv density----
allele_summary <- read_tsv("sv_allele_summary_justint_unbroken_13.tsv",col_names = F)
colnames(allele_summary) <- c("chr","start","end","alt_geno",
                              "prim_len","alt_len","inv")
allele_summary$chr <- gsub("scaffold_","chr",allele_summary$chr)
allele_summary <- filter(allele_summary, chr %in% chrs)

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
  count <- count_over_window(allele_summary,chrom,win_start,win_end)
  count_sv <- append(count_sv, count)
}
rm(i,win_start,win_end,count,chrom)

windows$count_sv <- count_sv

#Repeat Density----

repeats <- read_tsv("repeat_coordinates.tsv", col_names = F)
colnames(repeats) <- c("chr","start","end","family")
repeats$chr <- sub("HiC_scaffold_","chr",repeats$chr)
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
windows$gene_scaled <- scale(windows$prop_gene)
windows$sv_scaled <- scale(windows$count_sv)
windows$repeat_scaled <- scale(windows$repeat_prop)

#Ideogram Plots----

##Genes----
gene_ideograms <- list()

for (i in 1:13){
  chrom=paste0("chr",i)
  gene_ideograms[[i]] <- ggplot(data=filter(windows,chr==chrom),aes(x=win_start,y=prop_gene))+
    geom_point(size=0.5,color="grey")+geom_line()+
    labs(x="",y="")+
    theme_minimal(base_size = 12)+
    ylim(0,0.3)
  #print(gene_ideograms[[i]])
}
rm(i,chrom)

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
    ylim(0,2000)
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



#Simple Regression----

##SV on gene----

reg_sv_on_gene <- lm(gene_scaled~sv_scaled,windows)
sv_gene_summary <- summary(reg_sv_on_gene)
sv_gene_corr_p <- ggplot(data=windows,aes(x=sv_scaled,y=gene_scaled))+
  geom_point(alpha=0.3)+
  labs(x="SV Density (std.)",y="Gene Density (std.)")+
  theme_minimal()+
  geom_smooth(method="lm", level=0.9)+
  annotate(geom = "text", x=-0.5,y=5.2,
           label = paste("R2=", format(sv_gene_summary$adj.r.squared, digits=4)))+
  annotate(geom = "text", x=-0.5,y=5.5,
           label = paste("Slope =", format(coef(reg_sv_on_gene)["sv_scaled"][[1]],digits=3)))
sv_gene_corr_p

#by scaffold
sv_gene_corr_plots <- list()
for (i in 1:13){
  df_f <- filter(windows,chr==paste0("chr",i))
  summ <- summary(lm(gene_scaled~sv_scaled,df_f))
  sv_gene_corr_plots[[i]] <- ggplot(data=df_f,aes(x=sv_scaled,y=gene_scaled))+
    geom_point(alpha=0.3)+
    labs(x="SV Density (std.)",y="Gene Density (std.)",title=paste0("chr",i))+
    theme_minimal(base_size = 12)+
    geom_smooth(method="lm", level=0.9)+
    theme(plot.title=element_text(face="bold",hjust=0.5))
  print(sv_gene_corr_plots[[i]])
}
rm(i,df_f,summ)

sv_gene_corrs <- data.frame(chr=c(),slope=c(),r_square=c())
for (i in 1:13){
  chrom=paste0("chr",i)
  model=lm(sv_scaled~gene_scaled,filter(windows, chr==chrom))
  slope=coef(model)["sv_scaled"][[1]]
  r2 <- summary(model)$adj.r.squared
  sv_gene_corrs <- rbind(sv_gene_corrs, data.frame(chr=chrom,
                                                             slope=slope,
                                                             r_square=r2))
}
rm(i,chrom,model,slope,r2)


##Repeat on Gene----
repgene_lm <- lm(gene_scaled~repeat_scaled,windows)
repeat_gene_summary <- summary(repgene_lm)
repeat_gene_corr_p <- ggplot(data=windows,aes(x=repeat_scaled,y=gene_scaled))+
  geom_point(alpha=0.3)+
  labs(x="Repeat Density (std.)",y="Gene Density (std.)")+
  theme_minimal()+
  geom_smooth(method="lm", level=0.9)+
  annotate(geom = "text", x=1,y=5.2,
           label = paste("R2=", format(repeat_gene_summary$adj.r.squared, digits=4)))+
  annotate(geom = "text", x=1,y=5.5,
           label = paste("Slope =", format(coef(repgene_lm)["repeat_scaled"][[1]],digits=3)))
repeat_gene_corr_p

#by chr
repeat_gene_corr_plots <- list()
by_chr_repgene_corrs <- c()
by_chr_repgene_slopes <- c()
for (i in 1:13){
  df_f <- filter(windows,chr==paste0("chr",i))
  summ <- summary(lm(gene_scaled~repeat_scaled,df_f))
  by_chr_repgene_corrs <- append(by_chr_repgene_corrs,summ$adj.r.squared)
  by_chr_repgene_slopes <- append(by_chr_repgene_slopes, 
                                  coef(lm(repeat_scaled~gene_scaled,df_f))["repeat_scaled"][[1]])
  repeat_gene_corr_plots[[i]] <- ggplot(data=df_f,aes(x=repeat_scaled,y=gene_scaled))+
    geom_point(alpha=0.3)+
    labs(x="Repeat Density (std.)",y="Gene Density (std.)",title=paste0("chr",i))+
    theme_minimal(base_size = 12)+
    geom_smooth(method="lm", level=0.9)+
    theme(plot.title=element_text(face="bold",hjust=0.5))
  print(repeat_gene_corr_plots[[i]])
}
rm(df_f,summ,i)

repeat_gene_corrs <- data.frame(chr=genome$chr,
                                slope=by_chr_repgene_slopes,
                                corr=by_chr_repgene_corrs)

###repeat-sv correlation----
repsv_lm <- lm(repeat_scaled~sv_scaled,windows)
repeat_sv_summary <- summary(repsv_lm)
repeat_sv_corr_p <- ggplot(data=windows,aes(x=sv_scaled,y=repeat_scaled))+
  geom_point(alpha=0.3)+
  labs(x="SV Density (std.)",y="Repeat Density (std.)")+
  theme_minimal()+
  geom_smooth(method="lm", level=0.9)+
  annotate(geom = "text", x=2.3,y=2,
           label = paste("R2=", format(repeat_sv_summary$adj.r.squared,digits=4)))+
  annotate(geom = "text", x=2.3,y=2.3,
           label = paste("Slope =", format(coef(repsv_lm)["sv_scaled"][[1]],digits=3)))
repeat_sv_corr_p

#by chr
repeat_sv_corr_plots <- list()
by_chr_repsv_corrs <- c()
by_chr_repsv_slopes <- c()
for (i in 1:13){
  df_f <- filter(windows,chr==paste0("chr",i))
  summ <- summary(lm(repeat_scaled~sv_scaled,df_f))
  by_chr_repsv_corrs <- append(by_chr_repsv_corrs,summ$adj.r.squared)
  by_chr_repsv_slopes <- append(by_chr_repsv_slopes, coef(lm(repeat_scaled~sv_scaled,df_f))["sv_scaled"][[1]])
  repeat_sv_corr_plots[[i]] <- ggplot(data=df_f,aes(x=sv_scaled,y=repeat_scaled))+
    geom_point(alpha=0.3)+
    labs(x="SV Density (std.)",y="Repeat Density (std.)",title=paste0("chr",i))+
    theme_minimal()+
    geom_smooth(method="lm", level=0.9)+
    theme(plot.title=element_text(face="bold",hjust=0.5))
  print(repeat_sv_corr_plots[[i]])
}
rm(i,df_f,summ)

repeat_sv_corrs <- data.frame(chr=genome$chr,slope=by_chr_repsv_slopes,corr=by_chr_repsv_corrs)

#collate all by chr regressions into one data frame 

by_chr_simple_regressions <- data.frame(chr=repeat_sv_corrs$chr,
                                        sv_gene_slope=sv_gene_corrs$slope,
                                        sv_gene_r2=sv_gene_corrs$r_square,
                                        sv_repeat_slope=repeat_sv_corrs$slope,
                                        sv_repeat_r2=repeat_sv_corrs$corr,
                                        repeat_gene_slope=repeat_gene_corrs$slope,
                                        repeat_gene_r2=repeat_gene_corrs$corr)

##a panel with all three genome-wide simple correlations
ggarrange(ncol=3,nrow=1,sv_gene_corr_p,repeat_sv_corr_p,repeat_gene_corr_p)


#Multivariate Regression----

three_vars_lm <- lm(sv_scaled~repeat_scaled+gene_scaled+repeat_scaled:gene_scaled,windows)
three_vars_sum <- summary(three_vars_lm)
##Diagnostic Plots----
par(mfrow=c(2,2))
plot(three_vars_lm)
par(mfrow=c(1,1))


##by chr----
repeat_slope <- c()
repeat_err <- c()
repeat_p <- c()
gene_slope <- c()
gene_err <- c()
gene_p <- c()
int_slope <- c()
int_err <- c()
int_p <- c()
r2 <- c()


for (i in 1:13){
  chrom=paste0("chr",i)
  df_f <- filter(windows,chr==chrom)
  model <- lm(sv_scaled~repeat_scaled+gene_scaled+repeat_scaled:gene_scaled,df_f)
  summary <- summary(model)
  
  r2 <- append(r2,summary$adj.r.squared)
  
  #repeats
  repeat_slope <- append(repeat_slope,summary$coefficients[2,1])
  repeat_err <- append(repeat_err,summary$coefficients[2,2])
  repeat_p <- append(repeat_p,summary$coefficients[2,4])
  
  #genes
  gene_slope <- append(gene_slope,summary$coefficients[3,1])
  gene_err <- append(gene_err,summary$coefficients[3,2])
  gene_p <- append(gene_p,summary$coefficients[3,4])
  
  #interaction
  int_slope <- append(int_slope,summary$coefficients[4,1])
  int_err <- append(int_err,summary$coefficients[4,2])
  int_p <- append(int_p,summary$coefficients[4,4])
}

bychr_multivariate_regressions <- data.frame(chr=genome$chr,
                                             r2=r2,
                                             repeat_slope=repeat_slope,
                                             repeat_err=repeat_err,
                                             repeat_p=repeat_p,
                                             gene_slope=gene_slope,
                                             gene_err=gene_err,
                                             gene_p=gene_p,
                                             int_slope=int_slope,
                                             int_err=int_err,
                                             int_p=int_p)

##Scaffolds 9 ans 10----
ideograms_9_10 <- ggarrange(gene_ideograms[[9]],gene_ideograms[[10]],sv_ideograms[[9]],sv_ideograms[[10]],
          repeat_ideograms[[9]],repeat_ideograms[[10]],
          ncol=2,nrow=3)

gene_plots_9_10 <- list()
for (i in 9:10){
  chrom=paste0("chr",i)
  df_f <- filter(windows,chr==chrom)
  model <- lm(sv_scaled~prop_gene_scaled,df_f)
  r2 <- summary(model)$adj.r.squared
  slope <- coef(model)["prop_gene_scaled"][[1]]
  gene_plots_9_10[[i]] <- ggplot(data=df_f,aes(x=prop_gene_scaled,y=count_sv_scaled))+
    geom_point(alpha=0.3)+
    labs(x="Gene Density (std.)",y="SV Density (std.)",title=paste0("chr",i))+
    theme_minimal(base_size = 12)+
    geom_smooth(method="lm", level=0.9)+
    theme(plot.title=element_text(face="bold",hjust=0.5))+
    annotate(geom = "text", x=4,y=-1.3,
             label = paste("R2 =", format(r2, digits=4))) +
    annotate(geom = "text", x=4,y=-1,
             label = paste("Slope =",format(slope,digits=4)))
  print(gene_plots_noout[[i]])
}

repeat_plots_9_10 <- list()
models_9_10 <- list()
for (i in 9:10){
  chrom=paste0("chr",i)
  df_f <- filter(windows_scaled,chr==chrom)
  models_9_10[[i]] <- lm(count_sv~repeat_prop,df_f)
  r2 <- summary(models_9_10[[i]])$adj.r.squared
  slope <- coef(models_9_10[[i]])["repeat_prop"][[1]]
  repeat_plots_9_10[[i]] <- ggplot(data=df_f,aes(x=repeat_prop,y=count_sv))+
    geom_point(alpha=0.3)+
    labs(x="Repeat Density (std.)",y="SV Density (std.)",title=paste0("chr",i))+
    theme_minimal(base_size = 12)+
    geom_smooth(method="lm", level=0.9)+
    theme(plot.title=element_text(face="bold",hjust=0.5))
  print(repeat_plots_9_10[[i]])
}

repeat_plots_9_10[[9]] <- repeat_plots_9_10[[9]]+
annotate(geom = "text", x=-1.5,y=-1.8,
         label = paste("R2 =", format(summary(models_9_10[[9]])$adj.r.squared, digits=4))) +
  annotate(geom = "text", x=-1.5,y=-1.5,
           label = paste("Slope =",format(coef(models_9_10[[9]])["repeat_prop"][[1]],digits=4)))

repeat_plots_9_10[[10]] <- repeat_plots_9_10[[10]]+
  annotate(geom = "text", x=-2.5,y=-1.6,
           label = paste("R2 =", format(summary(models_9_10[[10]])$adj.r.squared, digits=4))) +
  annotate(geom = "text", x=-2.5,y=-1.3,
           label = paste("Slope =",format(coef(models_9_10[[10]])["repeat_prop"][[1]],digits=4)))

corr_plots_9_10 <- ggarrange(repeat_plots_9_10[[9]],repeat_plots_9_10[[10]],
                             gene_plots_9_10[[9]],gene_plots_9_10[[10]])

ggarrange(ideograms_9_10,corr_plots_9_10)


  
  


