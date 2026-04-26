##ARGUMENTS
args <- commandArgs(trailingOnly = TRUE)
missingness_tolerance <- as.numeric(args[1])
wd <- args[2]
##expects to to find input vcf in working directory
in_vcf <- args[3]
out_vcf <- args[4]

library(vcfR)
library(tidyverse)

setwd(wd)
vcf <- read.vcfR(in_vcf)

#isolate the genotypes; to be filtered
genotypes <- vcf@gt
#search for the sample names of the parents (in my data, parents have a library name starting
#with a P instead of a "-"; I'm searching for them this way)
parents <- grep("libP",colnames(genotypes)[-1],value=T)
#and, inversely, the megagametophytes
mgs <- grep("libP",colnames(genotypes)[-1],value=T,invert = T)

#now to the meat and potatoes.
#Filtering::
#####Parent call cannot be missing or SNP is thrown out.
#####Parent calls must both have GQ >=10 or SNP is thrown out.
#####Megagametophyte genotype call must have GQ >= 10 or it's set to missing
#####Megagametophyte genotype must match one of the parental alleles or it's set to missing
#####SNP must have 50% missingness among all megagametophytes or SNP is thrown out.

print("[M]: Beginning Filtering...")
ori_varnum=nrow(genotypes)

genotypes_filtered <- matrix(nrow=0,ncol=103,dimnames = dimnames(genotypes))
for (i in 1:nrow(genotypes)){
  
  candidate_snp=genotypes[i,]
  
  #check for true missing
  if (strsplit(candidate_snp[parents[1]],split=":")[[1]][1] == "."){
    next
  }
  
  #Filter based on genotype quality of the parent
  #if the GQ is missing or less than 10 for either parent, simply remove snp
  gq_p1 <- strsplit(candidate_snp[parents[1]],split=":")[[1]][4]
  gq_p2 <- strsplit(candidate_snp[parents[2]],split=":")[[1]][4]
  #if either parent has a truly missing genotype quality, next
  if (gq_p1 == "." || gq_p2 == ".") {
    next
  }
  gq_p1=as.integer(gq_p1)
  gq_p2=as.integer(gq_p2)
  if (gq_p1 < 10 || gq_p2 < 10) {
    next
  }
  
  #SNP is potentially viable. Capture parental alleles
  parent_alleles <- c(
    strsplit(strsplit(candidate_snp[parents[1]],
                             split=":")[[1]][1],split="|")[[1]][1],
    strsplit(strsplit(candidate_snp[parents[1]],
                             split=":")[[1]][1],split="|")[[1]][3],
    strsplit(strsplit(candidate_snp[parents[2]],
                             split=":")[[1]][1],split="|")[[1]][1],
    strsplit(strsplit(candidate_snp[parents[2]],
                             split=":")[[1]][1],split="|")[[1]][3]
  )
  
  #we're going to filter on missingness, and also genotype quality. If the genotype quality
  #for a MG is less than 10, the call is set to missing.
  missing_count=0
  #for each mg sample, assess whether it's missing or whether it matches one of the parents
  #else, it should be assigned a missing value
  for (mg in mgs) {
    gq=strsplit(candidate_snp[mg][[1]],split=":")[[1]][4]
    if (gq == ".") {
      gq=0
    } else {
      gq=as.integer(gq)
    }
   if (gq < 10){
     #if site has a call less than 10 GQ, set it to missing
     candidate_snp[mg][[1]] <- "0:0,0:0:0:0,0"
     missing_count=missing_count+1
   } else {
     allele=strsplit(candidate_snp[mg][[1]],split=":")[[1]][1]
     #if allele (which has a call) matches one of the parent alleles
     if (allele %in% parent_alleles) {
       #potentially keep record
       #determined at missingness stage
       next
      } else {
        #set the sample as missing
        candidate_snp[mg][[1]] <- "0:0,0:0:0:0,0"
        missing_count=missing_count+1
        }
   }
  }
  
  #filter based on missingness
  #100 mg, 50% missingness is 50
  if (missing_count <= (missingness_tolerance*length(mgs))) {
    #keep record
    genotypes_filtered <- rbind(genotypes_filtered,
                                candidate_snp,
                                deparse.level = 0)
  } else {
    #don't keep record
    next
  }
}

filt_varnum <- nrow(genotypes_filtered)

vcf@gt <- genotypes_filtered

write.vcf(vcf,file=out_vcf)
print("[M]: Created filtered VCF.")
print(paste("[M]: Original variant count: ",ori_varnum))
print(paste("[M]: Filtered variant count: ",filt_varnum))

  
