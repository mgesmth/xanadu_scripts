library(BatchMap)

#test segregation and select seg type and allow an outcross object

test.segregation_outcross=function(x) {
    if (is(x, "outcross")) {
        y <- list(Marker = dimnames(x$geno)[[2]], Results.of.tests = sapply(1:x$n.mar,
            function(onemap.object, marker) test.segregation.of.a.marker(onemap.object,
                marker), onemap.object = x))
        class(y) <- c("onemap.segreg.test")
        invisible(y)
    }
    else stop("This is not a onemap object with raw data")
}

select_segreg=function(x, distorted = FALSE, numbers = FALSE, threshold = NULL) {
    if (!inherits(x, "onemap.segreg.test"))
        stop("This is not an object of class onemap.segreg.test")
    Z <- data.frame(Marker = x$Marker, p.value = unlist(x$Results.of.tests[3,
        ]))
    if (is.null(threshold))
        thr <- Bonferroni.alpha(x, global.alpha = 0.05)
    else thr <- Bonferroni.alpha(x, global.alpha = threshold)
    if (distorted == FALSE)
        Z <- subset(Z, p.value >= thr)
    else Z <- subset(Z, p.value < thr)
    if (numbers == TRUE)
        return(which(x$Marker %in% as.vector(Z[, 1])))
    else return(as.vector(Z[, 1]))
}

#the write_onemap_raw function
write_onemap_raw=function(onemap.obj = NULL, file.name = NULL) {
  if (inherits(onemap.obj, "outcross")) {
    cross <- "outcross"
  }
  else if (inherits(onemap.obj, "f2")) {
    cross <- "f2 intercross"
  }
  else if (inherits(onemap.obj, "backcross")) {
    cross <- "f2 backcross"
  }
  else if (inherits(onemap.obj, "riself")) {
    cross <- "ri self"
  }
  else if (inherits(onemap.obj, "risib")) {
    cross <- "ri sib"
  }
  if (is.null(file.name))
    file.name = paste0(tempfile(), ".raw")
  fileConn <- file(file.name, "w")
  head1 <- paste("data type", cross)
  head2 <- paste(onemap.obj$n.ind, onemap.obj$n.mar, as.numeric(!is.null(onemap.obj$CHROM)),
                 as.numeric(!is.null(onemap.obj$POS)), onemap.obj$n.phe)
  ind.names <- rownames(onemap.obj$geno)
  if (is.null(ind.names))
    ind.names <- paste0("ID", 1:onemap.obj$n.ind)
  geno.mat <- onemap.obj$geno
  if (is.vector(geno.mat))
    geno.mat <- matrix(geno.mat)
  if (inherits(onemap.obj, "outcross")) {
    geno.mat[which(geno.mat == 0)] <- "-"
    idx <- which(onemap.obj$segr.type == "A.1")
    geno.mat[, idx][which(geno.mat[, idx] == 1)] <- "ac"
    geno.mat[, idx][which(geno.mat[, idx] == 2)] <- "ad"
    geno.mat[, idx][which(geno.mat[, idx] == 3)] <- "bc"
    geno.mat[, idx][which(geno.mat[, idx] == 4)] <- "bd"
    idx <- which(onemap.obj$segr.type == "A.2")
    geno.mat[, idx][which(geno.mat[, idx] == 1)] <- "a"
    geno.mat[, idx][which(geno.mat[, idx] == 2)] <- "ac"
    geno.mat[, idx][which(geno.mat[, idx] == 3)] <- "ba"
    geno.mat[, idx][which(geno.mat[, idx] == 4)] <- "bc"
    idx <- which(onemap.obj$segr.type == "A.3")
    geno.mat[, idx][which(geno.mat[, idx] == 1)] <- "ac"
    geno.mat[, idx][which(geno.mat[, idx] == 2)] <- "a"
    geno.mat[, idx][which(geno.mat[, idx] == 3)] <- "bc"
    geno.mat[, idx][which(geno.mat[, idx] == 4)] <- "b"
    idx <- which(onemap.obj$segr.type == "A.4")
    geno.mat[, idx][which(geno.mat[, idx] == 1)] <- "ab"
    geno.mat[, idx][which(geno.mat[, idx] == 2)] <- "a"
    geno.mat[, idx][which(geno.mat[, idx] == 3)] <- "b"
    geno.mat[, idx][which(geno.mat[, idx] == 4)] <- "o"
    idx <- which(onemap.obj$segr.type == "B1.5" | onemap.obj$segr.type ==
                   "B2.6" | onemap.obj$segr.type == "B3.7")
    geno.mat[, idx][which(geno.mat[, idx] == 1)] <- "a"
    geno.mat[, idx][which(geno.mat[, idx] == 2)] <- "ab"
    geno.mat[, idx][which(geno.mat[, idx] == 3)] <- "b"
    idx <- which(onemap.obj$segr.type == "D1.9" | onemap.obj$segr.type ==
                   "D2.14")
    geno.mat[, idx][which(geno.mat[, idx] == 1)] <- "ac"
    geno.mat[, idx][which(geno.mat[, idx] == 2)] <- "bc"
    idx <- which(onemap.obj$segr.type == "D1.10" | onemap.obj$segr.type ==
                   "D2.15")
    geno.mat[, idx][which(geno.mat[, idx] == 1)] <- "a"
    geno.mat[, idx][which(geno.mat[, idx] == 2)] <- "ab"
    idx <- which(onemap.obj$segr.type == "D1.11" | onemap.obj$segr.type ==
                   "D2.16")
    geno.mat[, idx][which(geno.mat[, idx] == 1)] <- "a"
    geno.mat[, idx][which(geno.mat[, idx] == 2)] <- "b"
    idx <- which(onemap.obj$segr.type == "D1.12" | onemap.obj$segr.type ==
                   "D2.17")
    geno.mat[, idx][which(geno.mat[, idx] == 1)] <- "ab"
    geno.mat[, idx][which(geno.mat[, idx] == 2)] <- "a"
    idx <- which(onemap.obj$segr.type == "D1.13" | onemap.obj$segr.type ==
                   "D2.18" | onemap.obj$segr.type == "C.8")
    geno.mat[, idx][which(geno.mat[, idx] == 1)] <- "a"
    geno.mat[, idx][which(geno.mat[, idx] == 2)] <- "o"
  }
  if (inherits(onemap.obj, c("f2", "backcross"))) {
    geno.mat[which(geno.mat == 0)] <- "-"
    idx <- which(onemap.obj$segr.type == "A.H.B" | onemap.obj$segr.type ==
                   "A.H")
    geno.mat[, idx][which(geno.mat[, idx] == 1)] <- "a"
    geno.mat[, idx][which(geno.mat[, idx] == 2)] <- "ab"
    geno.mat[, idx][which(geno.mat[, idx] == 3)] <- "b"
    idx <- which(onemap.obj$segr.type == "D.B")
    geno.mat[, idx][which(geno.mat[, idx] == 2)] <- "b"
    geno.mat[, idx][which(geno.mat[, idx] == 1)] <- "d"
    idx <- which(onemap.obj$segr.type == "C.A")
    geno.mat[, idx][which(geno.mat[, idx] == 2)] <- "a"
    geno.mat[, idx][which(geno.mat[, idx] == 1)] <- "c"
  }
  if (inherits(onemap.obj, c("riself", "risib"))) {
    geno.mat[which(geno.mat == 0)] <- "-"
    geno.mat[which(geno.mat == 1)] <- "a"
    geno.mat[which(geno.mat == 3)] <- "b"
  }
  mat <- data.frame(paste0(rep("*", onemap.obj$n.mar), colnames(onemap.obj$geno)),
                    onemap.obj$segr.type, t(geno.mat))
  colnames(mat) <- rownames(mat) <- NULL
  mat <- apply(mat, 1, function(x) paste(x, collapse = " "))
  writeLines(c(head1, head2, paste(ind.names, collapse = " "),
               mat), con = fileConn)
  if (onemap.obj$n.phe > 0) {
    onemap.obj$pheno[which(is.na(onemap.obj$pheno))] <- "-"
    fen <- paste0("*", paste(colnames(onemap.obj$pheno),
                             apply(onemap.obj$pheno, 2, function(x) paste(x, collapse = " "))))
    writeLines(fen, con = fileConn)
  }
  if (length(onemap.obj$CHROM) > 0) {
    onemap.obj$pheno[which(is.na(onemap.obj$pheno))] <- "-"
    chrom <- paste(paste0("*", "CHROM"), paste(onemap.obj$CHROM,
                                               collapse = " "))
    writeLines(chrom, con = fileConn)
  }
  if (length(onemap.obj$POS) > 0) {
    onemap.obj$pheno[which(is.na(onemap.obj$pheno))] <- "-"
    pos <- paste(paste0("*", "POS"), paste(onemap.obj$POS,
                                           collapse = " "))
    writeLines(pos, con = fileConn)
  }
  close(fileConn)
}

#suggest LOD
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


#Plotting maps functions
#get RF/LOD scores -- from script "get_info_2pt.R" on the onemap Github page
#this, I believe, is an internal function required for the rf_graph_table() function
#was hard to find!
get_mat_rf_out<- function(input.seq, LOD=FALSE, max.rf=0.5, min.LOD=0) {
    if(!inherits(input.seq,"sequence")) stop(deparse(substitute(input.seq))," is not an object of class 'sequence'")
    if(length(input.seq$seq.num) < 2) stop("The sequence must have at least 2 markers")
    n.mrk<-length(input.seq$seq.num)
    mrk.names <- colnames(input.seq$data.name$geno)[input.seq$seq.num]
    ## create reconmbination fraction matrix 
    r <- matrix(NA,n.mrk,n.mrk)
    dimnames(r)<-list(mrk.names, mrk.names)
    if(LOD)
    {
        for(i in 1:(n.mrk-1)) {
            for(j in (i+1):n.mrk) {
                k<-sort(c(input.seq$seq.num[i], input.seq$seq.num[j]))
                rfs<-sapply(input.seq$twopt$analysis, function(x,i,j) x[i,j], k[2], k[1]) 
                LODs<-sapply(input.seq$twopt$analysis, function(x,i,j) x[i,j], k[1], k[2]) 
                ## check if any assignment meets the criteria
                phases <- which((LODs >= min.LOD) & rfs <= max.rf)
                if(length(phases) == 0)
                {
                    r[i,j] <- NA
                    r[j,i] <- NA
                }
                else
                {
                    r.temp<-rfs[phases[which.max(LODs[phases])]]
                    if(r.temp > 0.5) r.temp<-0.5
                    r[i,j]<-r.temp
                    r[j,i]<-max(LODs[phases])
                }
            }
        }
    }
    else
    {
        for(i in 1:(n.mrk-1)) {
            for(j in (i+1):n.mrk) {
                k<-sort(c(input.seq$seq.num[i], input.seq$seq.num[j]))
                rfs<-sapply(input.seq$twopt$analysis, function(x,i,j) x[i,j], k[2], k[1]) 
                LODs<-sapply(input.seq$twopt$analysis, function(x,i,j) x[i,j], k[1], k[2]) 
                ## check if any assignment meets the criteria
                phases <- which((LODs >= min.LOD) & rfs <= max.rf)
                if(length(phases) == 0)
                {
                    r[j,i] <-  r[i,j] <- NA
                }
                else
                {
                    r.temp<-rfs[phases[which.max(LODs[phases])]]
                    if(r.temp > 0.5) r.temp<-0.5
                    r[j,i]<-r[i,j]<-r.temp
                }
            }
        } 
    }
    return(r)
}


#plot rfs after map creation
rf_graph_table=function (input.seq, graph.LOD = FALSE, main = NULL, inter = FALSE, 
  html.file = NULL, mrk.axis = "numbers", base.size = NULL, lab.xy = NULL, n.colors = 4, 
  display = TRUE) 
{
  if (!any(inherits(input.seq, "sequence"))) 
    stop(deparse(substitute(input.seq)), " is not an object of class 'sequence'")
  if (!(mrk.axis == "names" | mrk.axis == "numbers" | mrk.axis == 
    "none")) 
    stop("This mrk.axis argument is not defined, choose 'names', 'numbers' or 'none'")
  if (!any(inherits(input.seq$data.name, "outcross"))) {
    stop(deparse(substitute(input.seq$data.name)), " is not an object of class 'outcross'")
  } else {
    #number of markers in the map
    n.mrk <- length(input.seq$seq.num)
    if (inter) {
      #input.seq$twopt$analysis is a matrix describing the pwrfs between each pair of markers
      #x here is the rf matrix, w is the vector of the marker numbers
      #LOD is a matrix with four elements (the four PCPs) containing the LOD scores between each pair of markers
      LOD <- lapply(input.seq$twopt$analysis, function(x, 
        w) {
        #initialize a matrix of length and width w full of zeros
        #the length(w) is the number of markers
        m <- matrix(0, nrow = length(w), ncol = length(w))
        #create another matrix representing all the possible pairings of all markers
        k <- matrix(c(rep(w[1:(length(w))], each = length(w)), 
          rep(w[1:(length(w))], length(w))), ncol = 2)
        #remove cells where the comparison is between the same marker
        k <- k[-which(k[, 1] == k[, 2]), ]
        #transpose the matrix, and sort the matrix by row (arg2=1)
        k <- t(apply(k, 1, sort))
        #find duplicate cells and remove them
        k <- k[-which(duplicated(k)), ]
        LOD.temp <- x[k[, c(1, 2)]]
        m[lower.tri((m))] <- LOD.temp
        m[upper.tri(m)] <- t(m)[upper.tri(m)]
        return(m)
      }, input.seq$seq.num)
    }
    mat <- t(get_mat_rf_out(input.seq, LOD = TRUE, max.rf = 0.501, 
      min.LOD = -0.1))
  }
  mat[row(mat) > col(mat) & mat > 0.5] <- 0.5
  mat[row(mat) < col(mat)][mat[row(mat) < col(mat)] < 0.1] <- 0.1
  diag(mat) <- NA
  colnames(mat) <- rownames(mat) <- colnames(input.seq$data.name$geno)[input.seq$seq.num]
  if (mrk.axis == "numbers") 
    colnames(mat) <- rownames(mat) <- input.seq$seq.num
  if (inherits(input.seq$data.name, c("outcross"))) {
    types <- input.seq$data.name$segr.type.num[input.seq$seq.num]
    for (i in 1:length(types)) for (j in 1:(length(types) - 
      1)) if ((types[i] == 7 & types[j] == 6) | (types[i] == 
      6 & types[j] == 7)) {
      mat[i, j] <- mat[j, i] <- NA
    }
  }
  types <- input.seq$data.name$segr.type[input.seq$seq.num]
  if (length(input.seq$seq.rf) > 1) {
    for (i in 1:(n.mrk - 1)) {
      mat[i + 1, i] <- input.seq$seq.rf[i]
    }
  }
  missing <- 100 * apply(input.seq$data.name$geno[, input.seq$seq.num], 
    2, function(x) sum(x == 0))/input.seq$data.name$n.ind
  mat.LOD <- mat.rf <- mat
  mat.LOD[lower.tri(mat.LOD)] <- t(mat.LOD)[lower.tri(mat.LOD)]
  mat.rf[upper.tri(mat.rf)] <- t(mat.rf)[upper.tri(mat.LOD)]
  if (inherits(input.seq$data.name, c("outcross", "f2"))) {
    if (inter) {
      colnames(LOD$CC) <- rownames(LOD$CC) <- colnames(mat.rf)
      colnames(LOD$CR) <- rownames(LOD$CR) <- colnames(mat.rf)
      colnames(LOD$RC) <- rownames(LOD$RC) <- colnames(mat.rf)
      colnames(LOD$RR) <- rownames(LOD$RR) <- colnames(mat.rf)
      df.graph <- Reduce(function(x, y) merge(x, y, all = TRUE), 
        list(reshape2::melt(round(mat.rf, 2), value.name = "rf"), 
          reshape2::melt(round(mat.LOD, 2), value.name = "LOD"), 
          reshape2::melt(round(LOD$CC, 2), value.name = "CC"), 
          reshape2::melt(round(LOD$CR, 2), value.name = "CR"), 
          reshape2::melt(round(LOD$RC, 2), value.name = "RC"), 
          reshape2::melt(round(LOD$RR, 2), value.name = "RR")))
      colnames(df.graph)[5:8] <- paste0("LOD.", c("CC", 
        "CR", "RC", "RR"))
    }
    else {
      df.graph <- Reduce(function(x, y) merge(x, y, all = TRUE), 
        list(reshape2::melt(round(mat.rf, 2), value.name = "rf"), 
          reshape2::melt(round(mat.LOD, 2), value.name = "LOD")))
    }
  }
  else {
    df.graph <- merge(reshape2::melt(round(mat.rf, 2), value.name = "rf"), 
      reshape2::melt(round(mat.LOD, 2), value.name = "LOD"))
  }
  colnames(df.graph)[c(1, 2)] <- c("x", "y")
  if (mrk.axis == "numbers") {
    df.graph$x <- factor(df.graph$x, levels = as.character(input.seq$seq.num))
    df.graph$y <- factor(df.graph$y, levels = as.character(input.seq$seq.num))
  }
  missing <- paste0(round(missing, 2), "%")
  mrk.type.x <- data.frame(x = colnames(mat.rf), x.type = types)
  mrk.type.y <- data.frame(y = colnames(mat.rf), y.type = types)
  missing.x <- data.frame(x = colnames(mat.rf), x.missing = missing)
  missing.y <- data.frame(y = colnames(mat.rf), y.missing = missing)
  df.graph <- Reduce(function(x, y) merge(x, y, all = TRUE), 
    list(df.graph, mrk.type.x, mrk.type.y, missing.x, missing.y))
  if (inherits(input.seq$data.name, c("outcross", "f2"))) {
    if (graph.LOD != TRUE) {
      if (inter) {
        p <- ggplot(aes(x, y, x.type = x.type, y.type = y.type, 
          x.missing = x.missing, y.missing = y.missing, 
          fill = rf, LOD.CC = LOD.CC, LOD.CR = LOD.CR, 
          LOD.RC = LOD.RC, LOD.RR = LOD.RR), data = df.graph) + 
          geom_tile() + scale_fill_gradientn(colours = grDevices::rainbow(n.colors), 
          na.value = "white") + theme(axis.text.x = element_text(angle = 90, 
          hjust = 1))
      }
      else {
        p <- ggplot(aes(x, y, x.type = x.type, y.type = y.type, 
          x.missing = x.missing, y.missing = y.missing, 
          fill = rf), data = df.graph) + geom_tile() + 
          scale_fill_gradientn(colours = grDevices::rainbow(n.colors), 
            na.value = "white") + theme(axis.text.x = element_text(angle = 90, 
          hjust = 1))
      }
    }
    else {
      if (inter) {
        p <- ggplot(aes(x, y, x.type = x.type, y.type = y.type, 
          x.missing = x.missing, y.missing = y.missing, 
          rf = rf, fill = LOD, LOD.CC = LOD.CC, LOD.CR = LOD.CR, 
          LOD.RC = LOD.RC, LOD.RR = LOD.RR), data = df.graph) + 
          geom_tile() + scale_fill_gradientn(colours = rev(grDevices::rainbow(n.colors)), 
          na.value = "white") + theme(axis.text.x = element_text(angle = 90, 
          hjust = 1))
      }
      else {
        p <- ggplot(aes(x, y, x.type = x.type, y.type = y.type, 
          x.missing = x.missing, y.missing = y.missing, 
          rf = rf, fill = LOD), data = df.graph) + geom_tile() + 
          scale_fill_gradientn(colours = rev(grDevices::rainbow(n.colors)), 
            na.value = "white") + theme(axis.text.x = element_text(angle = 90, 
          hjust = 1))
      }
    }
  }
  else {
    if (graph.LOD != TRUE) {
      p <- ggplot(aes(x, y, x.missing = x.missing, y.missing = y.missing, 
        fill = rf, LOD = LOD), data = df.graph) + geom_tile() + 
        scale_fill_gradientn(colours = grDevices::rainbow(n.colors), 
          na.value = "white") + theme(axis.text.x = element_text(angle = 90, 
        hjust = 1))
    }
    else {
      p <- ggplot(aes(x, y, x.missing = x.missing, y.missing = y.missing, 
        rf = rf, fill = LOD), data = df.graph) + geom_tile() + 
        scale_fill_gradientn(colours = rev(grDevices::rainbow(n.colors)), 
          na.value = "white") + theme(axis.text.x = element_text(angle = 90, 
        hjust = 1))
    }
  }
  if (is.null(lab.xy)) {
    p <- p + labs(x = " ", y = " ")
  }
  else {
    if (length(lab.xy) != 2) {
      warning("You should give a character vector with two components to axis labels")
    }
    else {
      p <- p + labs(x = lab.xy[1], y = lab.xy[2])
    }
  }
  if (mrk.axis == "none") {
    p <- p + theme(axis.text.x = element_blank(), axis.text.y = element_blank())
  }
  if (!is.null(main)) {
    p <- p + ggtitle(main)
  }
  if (!is.null(base.size)){
    p = p + theme(text = element_text(size = base.size))
  }
  if (inter) {
    if (is.null(html.file)) {
      stop("For interactive mode you must define a name for the outputted html file in 'html.file' argument.")
    }
    else {
      p <- plotly::ggplotly(p)
      if (display) {
        htmlwidgets::saveWidget(p, file = html.file)
        browseURL(html.file)
      }
      else {
        p
      }
    }
  }
  else {
    p
  }
}


save.image("onemap_functions_for_batchmap.RData")
