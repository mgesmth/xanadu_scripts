library(BatchMap)

#input_file="DFI_linkage_stringent_batchmap.txt"
#input_file="sim7.5k.txt"
input_file="DFI_linkage_stringent_maf.txt

#read data in
outcross <- read.outcross2(input_file)
bins <- find.bins(outcross, exact = FALSE)
#bin the data to remove redundant markers
outcross_clean <- create.data.bins(outcross, bins)
#from onemap, the write_onemap_raw function
write_onemap_raw <- function(onemap.obj = NULL, file.name = NULL) {
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

write_onemap_raw(onemap.obj = outcross_clean,file="binned_onemap_maf.raw")
