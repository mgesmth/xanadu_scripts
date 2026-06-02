#!/bin/env/R

function (input.seq, graph.LOD = FALSE, main = NULL, inter = FALSE, 
  html.file = NULL, mrk.axis = "numbers", lab.xy = NULL, n.colors = 4, 
  display = TRUE) 
{
  if (!any(inherits(input.seq, "sequence"))) 
    stop(deparse(substitute(input.seq)), " is not an object of class 'sequence'")
  if (!(mrk.axis == "names" | mrk.axis == "numbers" | mrk.axis == 
    "none")) 
    stop("This mrk.axis argument is not defined, choose 'names', 'numbers' or 'none'")
  if (inherits(input.seq$data.name, c("outcross", "f2"))) {
    n.mrk <- length(input.seq$seq.num)
    if (inter) {
      LOD <- lapply(input.seq$twopt$analysis, function(x, 
        w) {
        m <- matrix(0, nrow = length(w), ncol = length(w))
        k <- matrix(c(rep(w[1:(length(w))], each = length(w)), 
          rep(w[1:(length(w))], length(w))), ncol = 2)
        k <- k[-which(k[, 1] == k[, 2]), ]
        k <- t(apply(k, 1, sort))
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
  else {
    n.mrk <- length(input.seq$seq.num)
    if (inter) {
      LOD <- matrix(0, length(input.seq$seq.num), length(input.seq$seq.num))
      k <- matrix(c(rep(input.seq$seq.num[1:(length(input.seq$seq.num))], 
        each = length(input.seq$seq.num)), rep(input.seq$seq.num[1:(length(input.seq$seq.num))], 
        length(input.seq$seq.num))), ncol = 2)
      k <- k[-which(k[, 1] == k[, 2]), ]
      k <- t(apply(k, 1, sort))
      k <- k[-which(duplicated(k)), ]
      LOD.temp <- input.seq$twopt$analysis[k[, c(1, 2)]]
      LOD[lower.tri((LOD))] <- LOD.temp
      LOD[upper.tri(LOD)] <- t(LOD)[upper.tri(LOD)]
    }
    mat <- t(get_mat_rf_in(input.seq, LOD = TRUE, max.rf = 0.501, 
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
        list(melt(round(mat.rf, 2), value.name = "rf"), 
          melt(round(mat.LOD, 2), value.name = "LOD"), 
          melt(round(LOD$CC, 2), value.name = "CC"), 
          melt(round(LOD$CR, 2), value.name = "CR"), 
          melt(round(LOD$RC, 2), value.name = "RC"), 
          melt(round(LOD$RR, 2), value.name = "RR")))
      colnames(df.graph)[5:8] <- paste0("LOD.", c("CC", 
        "CR", "RC", "RR"))
    }
    else {
      df.graph <- Reduce(function(x, y) merge(x, y, all = TRUE), 
        list(melt(round(mat.rf, 2), value.name = "rf"), 
          melt(round(mat.LOD, 2), value.name = "LOD")))
    }
  }
  else {
    df.graph <- merge(melt(round(mat.rf, 2), value.name = "rf"), 
      melt(round(mat.LOD, 2), value.name = "LOD"))
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
          geom_tile() + scale_fill_gradientn(colours = rainbow(n.colors), 
          na.value = "white") + theme(axis.text.x = element_text(angle = 90, 
          hjust = 1))
      }
      else {
        p <- ggplot(aes(x, y, x.type = x.type, y.type = y.type, 
          x.missing = x.missing, y.missing = y.missing, 
          fill = rf), data = df.graph) + geom_tile() + 
          scale_fill_gradientn(colours = rainbow(n.colors), 
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
          geom_tile() + scale_fill_gradientn(colours = rev(rainbow(n.colors)), 
          na.value = "white") + theme(axis.text.x = element_text(angle = 90, 
          hjust = 1))
      }
      else {
        p <- ggplot(aes(x, y, x.type = x.type, y.type = y.type, 
          x.missing = x.missing, y.missing = y.missing, 
          rf = rf, fill = LOD), data = df.graph) + geom_tile() + 
          scale_fill_gradientn(colours = rev(rainbow(n.colors)), 
            na.value = "white") + theme(axis.text.x = element_text(angle = 90, 
          hjust = 1))
      }
    }
  }
  else {
    if (graph.LOD != TRUE) {
      p <- ggplot(aes(x, y, x.missing = x.missing, y.missing = y.missing, 
        fill = rf, LOD = LOD), data = df.graph) + geom_tile() + 
        scale_fill_gradientn(colours = rainbow(n.colors), 
          na.value = "white") + theme(axis.text.x = element_text(angle = 90, 
        hjust = 1))
    }
    else {
      p <- ggplot(aes(x, y, x.missing = x.missing, y.missing = y.missing, 
        rf = rf, fill = LOD), data = df.graph) + geom_tile() + 
        scale_fill_gradientn(colours = rev(rainbow(n.colors)), 
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
  if (inter) {
    if (is.null(html.file)) {
      stop("For interactive mode you must define a name for the outputted html file in 'html.file' argument.")
    }
    else {
      p <- ggplotly(p)
      if (display) {
        saveWidget(p, file = html.file)
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
