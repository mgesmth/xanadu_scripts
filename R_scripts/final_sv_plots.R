library(ggplot2)
library(tidyverse)
library(ggpubr)
library(karyoploteR)

#get data in through sv and genome annotation files
setwd("~/Documents/PhD/final_structural_variants/")
allele_summary <- read_tsv("sv_allele_summary_filt2_unbroken_14.tsv",col_names = F)
colnames(allele_summary) <- c("scaffold","start","end","alt_geno","coast_geno",
                              "prim_len","alt_len","coast_len","inv")
sv_cat <- read_tsv("svs_categorized.tsv", col_names = F)
colnames(sv_cat) <- c("scaffold","start","end","type1","type2","genotype","lengths")

gene_coord <- read_tsv("genes_coordinates_14.tsv", col_names = F)
colnames(gene_coord) <- c("scaffold","start","end")


#set up karyoplote objects
##genome
genome <- read_tsv("mancur_genome_forkaryoplot.txt", col_names = T)
genome <- data.frame(chr=genome$ID,start=rep(1,14),end=genome$SIZE)
genome$chr <- paste(rep("chr",length(genome$chr)),genome$chr, sep="")
custom.genome <- toGRanges(genome)

##SVs
SV_kary <- data.frame(chr=allele_summary$scaffold,start=allele_summary$start,
                      end=allele_summary$end)
SV_kary$chr <- gsub("scaffold_","chr",SV_kary$chr)
SV_kary <- toGRanges(SV_kary)

#genes
gene_kary <- data.frame(chr=gene_coord$scaffold, start=gene_coord$start,
                        end=gene_coord$end)
gene_kary$chr <- gsub("scaffold_","chr",gene_kary$chr)
gene_kary <- toGRanges(gene_kary)

#Ideogram----
##all
###5Mb resolution
pp <- getDefaultPlotParams(plot.type = 2)
kp <- plotKaryotype(genome=custom.genome, plot.type = 2, chromosomes="all", plot.params = pp)
kp <- kpDataBackground(kp, color="white", data.panel = 1)
kp <- kpDataBackground(kp, color="white", data.panel = 2)
kp <- kpPlotDensity(kp, data = SV_kary, data.panel = 1, col="orange", window.size = 5e6)
kp <- kpAxis(kp, ymax=kp$latest.plot$computed.values$max.density, cex=0.8, data.panel = 1, side=2)
sv_density_5Mb <- kp$latest.plot$computed.values$density
kp <- kpPlotDensity(kp, data = gene_kary, data.panel = 2, col="skyblue", window.size = 5e6)
kp <- kpAxis(kp, ymax=kp$latest.plot$computed.values$max.density, cex=0.8, data.panel = 2, side=2)
gene_density_5Mb <- kp$latest.plot$computed.values$density

###10Mb Resolution
pp <- getDefaultPlotParams(plot.type = 2)
kp <- plotKaryotype(genome=custom.genome, plot.type = 2, chromosomes="all", plot.params = pp)
kp <- kpDataBackground(kp, color="white", data.panel = 1)
kp <- kpDataBackground(kp, color="white", data.panel = 2)
kp <- kpPlotDensity(kp, data = SV_kary, data.panel = 1, col="orange", window.size = 1e7)
kp <- kpAxis(kp, ymax=kp$latest.plot$computed.values$max.density, cex=0.8, data.panel = 1, side=2)
sv_density_10Mb <- kp$latest.plot$computed.values$density
kp <- kpPlotDensity(kp, data = gene_kary, data.panel = 2, col="skyblue", window.size = 1e7)
kp <- kpAxis(kp, ymax=kp$latest.plot$computed.values$max.density, cex=0.8, data.panel = 2, side=2)
gene_density_10Mb <- kp$latest.plot$computed.values$density

###25Mb resolution
pp <- getDefaultPlotParams(plot.type = 2)
kp <- plotKaryotype(genome=custom.genome, plot.type = 2, chromosomes="all", plot.params = pp)
kp <- kpDataBackground(kp, color="white", data.panel = 1)
kp <- kpDataBackground(kp, color="white", data.panel = 2)
kp <- kpPlotDensity(kp, data = SV_kary, data.panel = 1, col="orange", window.size = 2.5e7)
kp <- kpAxis(kp, ymax=kp$latest.plot$computed.values$max.density, cex=0.8, data.panel = 1, side=2)
sv_density_25Mb <- kp$latest.plot$computed.values$density
kp <- kpPlotDensity(kp, data = gene_kary, data.panel = 2, col="skyblue", window.size = 2.5e7)
kp <- kpAxis(kp, ymax=kp$latest.plot$computed.values$max.density, cex=0.8, data.panel = 2, side=2)
gene_density_25Mb <- kp$latest.plot$computed.values$density

###50Mb resolution
pp <- getDefaultPlotParams(plot.type = 2)
kp <- plotKaryotype(genome=custom.genome, plot.type = 2, chromosomes="all", plot.params = pp)
kp <- kpDataBackground(kp, color="white", data.panel = 1)
kp <- kpDataBackground(kp, color="white", data.panel = 2)
kp <- kpPlotDensity(kp, data = SV_kary, data.panel = 1, col="orange", window.size = 5e7)
kp <- kpAxis(kp, ymax=kp$latest.plot$computed.values$max.density, cex=0.8, data.panel = 1, side=2)
sv_density_50Mb <- kp$latest.plot$computed.values$density
kp <- kpPlotDensity(kp, data = gene_kary, data.panel = 2, col="skyblue", window.size = 5e7)
kp <- kpAxis(kp, ymax=kp$latest.plot$computed.values$max.density, cex=0.8, data.panel = 2, side=2)
gene_density_50Mb <- kp$latest.plot$computed.values$density

#Regressions

##5Mb
gene_on_sv_5mb <- data.frame(gene=gene_density_5Mb, sv=sv_density_5Mb)
reg_5mb <- lm(gene~sv, data=gene_on_sv_5mb)
gene_on_sv_plot_5mb <- ggplot(data=gene_on_sv_5mb, aes(x=sv, y=gene))+
  geom_point(colour="grey", fill="white")+
  xlab("SV Density")+ylab("Gene Density")+
  geom_smooth(method="lm", level=0.9)+
  annotate(geom = "text", x=750, y=25,
           label = paste("R2=", format(summary(reg_5mb)$adj.r.squared, digits=4))) +
  theme_classic(base_size = 18)
gene_on_sv_plot_5mb

##10Mb
gene_on_sv_10mb <- data.frame(gene=gene_density_10Mb, sv=sv_density_10Mb)
reg_10mb <- lm(gene~sv, data=gene_on_sv_10mb)
gene_on_sv_plot_10mb <- ggplot(data=gene_on_sv_10mb, aes(x=sv, y=gene))+
  geom_point(colour="grey", fill="white")+
  xlab("SV Density")+ylab("Gene Density")+
  geom_smooth(method="lm", level=0.9)+
  annotate(geom = "text", x=1250, y=50,
           label = paste("R2=", format(summary(reg_10mb)$adj.r.squared, digits=4))) +
  theme_classic(base_size = 18)
gene_on_sv_plot_10mb

##25Mb
gene_on_sv_25mb <- data.frame(gene=gene_density_25Mb, sv=sv_density_25Mb)
reg_25mb <- lm(gene~sv, data=gene_on_sv_25mb)
gene_on_sv_plot_25mb <- ggplot(data=gene_on_sv_25mb, aes(x=sv, y=gene))+
  geom_point(colour="grey", fill="white")+
  xlab("SV Density")+ylab("Gene Density")+
  geom_smooth(method="lm", level=0.9)+
  annotate(geom = "text", x=2800, y=110,
           label = paste("R2=", format(summary(reg_25mb)$adj.r.squared, digits=4))) +
  theme_classic(base_size = 18)
gene_on_sv_plot_25mb

##50Mb
gene_on_sv_50mb <- data.frame(gene=gene_density_50Mb, sv=sv_density_50Mb)
reg_50mb <- lm(gene~sv, data=gene_on_sv_50mb)
gene_on_sv_plot_50mb <- ggplot(data=gene_on_sv_50mb, aes(x=sv, y=gene))+
  geom_point(colour="grey", fill="white")+
  xlab("SV Density")+ylab("Gene Density")+
  geom_smooth(method="lm", level=0.9)+
  annotate(geom = "text", x=4700, y=220,
           label = paste("R2=", format(summary(reg_50mb)$adj.r.squared, digits=4))) +
  theme_classic(base_size = 18)
gene_on_sv_plot_50mb

ggarrange(gene_on_sv_plot_5mb,gene_on_sv_plot_10mb,gene_on_sv_plot_25mb,gene_on_sv_plot_50mb,
       labels=c("A","B","C","D"))


##by chromosome----

sv_density <- c()
chr_vec <- c()
window_vec <- c()
gene_density <- c()
for (i in 1:13){
  scaffold <- genome$chr[i]
  pp <- getDefaultPlotParams(plot.type = 2)
  kp <- plotKaryotype(genome=custom.genome, plot.type = 2, chromosomes=scaffold, plot.params = pp)
  kp <- kpDataBackground(kp, color="white", data.panel = 1)
  kp <- kpDataBackground(kp, color="white", data.panel = 2)
  kp <- kpPlotDensity(kp, data = SV_kary, data.panel = 1, col="orange", window.size = 5e7)
  kp <- kpAxis(kp, ymax=kp$latest.plot$computed.values$max.density, cex=0.8, data.panel = 1, side=2)
  sv_density <- append(sv_density, kp$latest.plot$computed.values$density)
  chr_vec <- append(chr_vec, rep(scaffold, length(kp$latest.plot$computed.values$density)))
  window_vec <- append(window_vec, seq(1, length(kp$latest.plot$computed.values$density)))
  kp <- kpPlotDensity(kp, data = gene_kary, data.panel = 2, col="skyblue", window.size = 5e7)
  kp <- kpAxis(kp, ymax=kp$latest.plot$computed.values$max.density, cex=0.8, data.panel = 2, side=2)
  gene_density <- append(gene_density, kp$latest.plot$computed.values$density)
}

labelled_gene_on_sv_density <- data.frame(chr=chr_vec,window=window_vec,
                                          sv_density=sv_density,
                                          gene_density=gene_density)

reg_labelled <- lm(gene_density~sv_density, data=labelled_gene_on_sv_density)


gene_on_sv_plot_labelled <- ggplot(data=labelled_gene_on_sv_density,
                                   aes(x=sv_density, y=gene_density,color=chr))+
  geom_point()+
  xlab("SV Density")+ylab("Gene Density")+
  #geom_smooth(method="lm", level=0.9, mapping = aes(x=sv_density, y=gene_density))+
  annotate(geom = "text", x=4700, y=220,
           label = paste("R2=",
                         format(summary(reg_50mb)$adj.r.squared, digits=4))) +
  theme_classic(base_size = 18)
gene_on_sv_plot_labelled
