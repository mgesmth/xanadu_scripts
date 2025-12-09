library(tidyverse)
library(ggplot2)
library(ggpubr)

for (i in 1:13) {
  chr_n=paste0("chr",i)
  var_name <- paste0(chr_n,"_p")
  print(var_name)
  if (i %in% c(1,5,9,13)){
    p <- ggplot(data=filter(windows, chr==chr_n), aes(x=start,y=avg))+
      geom_line()+
      labs(x="", y="")+
      ylim(0,25)+
      theme_minimal()+
      theme(panel.border = element_rect(linewidth = 1), panel.background = element_blank())+
      annotate(geom="rect",xmin=-Inf,xmax=Inf,ymin=23,ymax=Inf,
               fill="grey",colour="black")+
      annotation_custom(textGrob(paste0("Chromosome ",i),
                                 x=0.5,y=0.9,vjust = 0, hjust = 0.5))+
      theme(plot.margin=unit(c(0.001, 0.001, 0.001, 0.001), "cm"))
  } else {
    p <- ggplot(data=filter(windows, chr==chr_n), aes(x=start,y=avg))+
      geom_line()+
      labs(x="", y="")+
      ylim(0,25)+
      theme_minimal()+
      theme(panel.border = element_rect(linewidth = 1), panel.background = element_blank())+
      annotate(geom="rect",xmin=-Inf,xmax=Inf,ymin=23,ymax=Inf,
               fill="grey",colour="black")+
      theme(axis.text.y = element_blank())+
      annotation_custom(textGrob(paste0("Chromosome ",i),
                                 x=0.5,y=0.9,vjust = 0, hjust = 0.5))+
      theme(plot.margin=unit(c(0.001, 0.001, 0.001, 0.001), "cm"))
  }
  assign(var_name,p)
}


ggarrange(chr1_p,chr2_p,chr3_p,chr4_p,chr5_p,chr6_p,chr7_p,chr8_p,chr9_p,chr10_p,
          chr11_p,chr12_p,chr13_p)+
  annotation_custom(textGrob("Average Intron Length (kb)",x=0,y=0.5,rot=90))+
  annotation_custom(textGrob("Position (Mb)",x=0.5,y=0))+
  theme(plot.margin = unit(c(0.5,0.5,0.5,0.5),"cm"))
