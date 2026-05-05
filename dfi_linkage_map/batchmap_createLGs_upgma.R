library(BatchMap)

args <- commandArgs(trailingOnly = TRUE)
wd=args[1]
input_file=args[2]

setwd(wd)

outcross <- read.outcross2(input_file)

#estimate two-point r
twopt_table <- rf.2pts(outcross)
#find linkage groups
#suggest_lod from onemap; batchmap function doesn't work
suggest_lod <- function(x) {
  if (inherits(x, c("sequence", "onemap","outcross"))) {
    if (inherits(x, c("onemap","outcross")))
      num.tests <- choose(x$n.mar, 2)
    if (inherits(x, "sequence"))
      num.tests <- choose(length(x$seq.num), 2)
    LOD <- 0.2172 * qchisq(1 - 0.05/num.tests, 1)
    return(LOD)
  }
  else stop("This is not a onemap object with raw data")
}

group_upgma = function(input.seq, expected.groups = NULL, inter = TRUE, comp.mat = FALSE) {
    if (!any(inherits(input.seq, "sequence")))
        stop(deparse(substitute(input.seq)), " is not an object of class 'sequence'")
    if (inherits(input.seq$data.name, "outcross") | inherits(input.seq$data.name,
        "f2")) {
        n.mrk <- length(input.seq$seq.num)
        LOD <- lapply(input.seq$twopt$analysis, function(x, w) {
            m <- matrix(0, length(w), length(w))
            for (i in 1:(length(w) - 1)) {
                for (j in (i + 1):length(w)) {
                  z <- sort(c(w[i], w[j]))
                  m[j, i] <- m[i, j] <- x[z[1], z[2]]
                }
            }
            return(m)
        }, input.seq$seq.num)
        mat <- t(get_mat_rf_out(input.seq, LOD = TRUE, max.rf = 0.501,
            min.LOD = -0.1))
    }
    else {
        n.mrk <- length(input.seq$seq.num)
        LOD <- matrix(0, length(input.seq$seq.num), length(input.seq$seq.num))
        for (i in 1:(length(input.seq$seq.num) - 1)) {
            for (j in (i + 1):length(input.seq$seq.num)) {
                z <- sort(c(input.seq$seq.num[i], input.seq$seq.num[j]))
                LOD[j, i] <- LOD[i, j] <- input.seq$twopt$analysis[z[1],
                  z[2]]
            }
        }
        mat <- t(get_mat_rf_in(input.seq, LOD = TRUE, max.rf = 0.501,
            min.LOD = -0.1))
    }
    diag(mat) <- 0
    mn <- input.seq$data.name$CHROM[input.seq$seq.num]
    mn[is.na(mn)] <- "NH"
    dimnames(mat) <- list(mn, mn)
    hc.snp <- hclust(as.dist(mat), method = "average")
    ANSWER <- "flag"
    if (interactive() && inter) {
        dend.snp <- as.dendrogram(hc.snp)
        while (substr(ANSWER, 1, 1) != "y" && substr(ANSWER,
            1, 1) != "yes" && substr(ANSWER, 1, 1) != "Y" &&
            ANSWER != "") {
            dend1 <- color_branches(dend.snp, k = expected.groups)
            plot(dend1, leaflab = "none")
            if (is.null(expected.groups))
                expected.group <- as.numeric(readline("Enter the number of expected groups: "))
            z <- rect.hclust(hc.snp, k = expected.groups, border = "red")
            groups.snp <- cutree(tree = hc.snp, k = expected.groups)
            xy <- sapply(z, length)
            xt <- as.numeric(cumsum(xy) - ceiling(xy/2))
            yt <- 0.1
            points(x = xt, y = rep(yt, length(xt)), cex = 6,
                pch = 20, col = "lightgray")
            text(x = xt, y = yt, labels = pmatch(xy, table(groups.snp,
                useNA = "ifany")), adj = 0.5)
            ANSWER <- readline("Enter 'Y/n' to proceed or update the number of expected groups: ")
            if (substr(ANSWER, 1, 1) == "n" | substr(ANSWER,
                1, 1) == "no" | substr(ANSWER, 1, 1) == "N")
                stop("You decided to stop the function.")
            if (substr(ANSWER, 1, 1) != "y" && substr(ANSWER,
                1, 1) != "yes" && substr(ANSWER, 1, 1) != "Y" &&
                ANSWER != "")
                expected.groups <- as.numeric(ANSWER)
        }
    }
    if (is.null(expected.groups))
        stop("Inform the 'expected.groups' or use 'inter = TRUE'")
    seq.vs.grouped.snp <- NULL
    if (all(unique(mn) == "NH") & comp.mat) {
        comp.mat <- FALSE
        seq.vs.grouped.snp <- NULL
        warning("There is no physical reference to generate a comparison matrix")
    }
    groups.snp <- cutree(tree = hc.snp, k = expected.groups)
    if (comp.mat) {
        seq.vs.grouped.snp <- matrix(0, expected.groups, length(na.omit(unique(mn))) +
            1, dimnames = list(1:expected.groups, c(na.omit(unique(mn)),
            "NH")))
        for (i in 1:expected.groups) {
            x <- table(names(which(groups.snp == i)))
            seq.vs.grouped.snp[i, names(x)] <- x
        }
        idtemp2 <- apply(seq.vs.grouped.snp, 1, which.max)
        seq.vs.grouped.snp <- cbind(seq.vs.grouped.snp[, unique(idtemp2)],
            seq.vs.grouped.snp[, "NH"])
        cnm <- colnames(seq.vs.grouped.snp)
        cnm[cnm == ""] <- "NoChr"
        colnames(seq.vs.grouped.snp) <- cnm
    }
    else {
        seq.vs.grouped.snp <- NULL
    }
    names(groups.snp) <- input.seq$seq.num
    structure(list(data.name = input.seq$data.name, hc.snp = hc.snp,
        expected.groups = expected.groups, n.groups = length(unique(groups.snp)),
        groups = groups.snp, seq.num = input.seq$seq.num, seq.vs.grouped.snp = seq.vs.grouped.snp,
        LOD = input.seq$LOD, max.rf = input.seq$max.rf, twopt = input.seq$twopt),
        class = "group.upgma")
}

lg_upgma=group_upgma(make.seq(input.obj = twopt_table, "all"), expected.groups=13,inter=F,)

print(lg_upgma,detailed=F)

png("lg_upgma_tree.png")
plot(lg_upgma)
dev.off()


LG_list <- list()
for(i in 1:13){
  print(i)
  LG_list[[paste("LG",i,sep="_")]] <- make.seq(linkage_groups,i)
}

save.image("LGs_created_upgma.RData")
