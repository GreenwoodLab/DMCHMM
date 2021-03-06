.manhattanDMCs <- function(object, col, chrlabs, suggestiveline, genomewideline,
    highlight, logp, annotatePval, annotateTop, ...) {

    # Not sure why, but package check will warn without this.
    CHR = BP = P = index = NameBP = NULL

    # Check for sensible dataset
    if (is.null(metadata(object)$DMCHMM))
        stop("Input must be an object
    obtianed from findDMCs method.")

    if (missing(col)) {
        col = c("gray70", "gray50")
    } else if (!is.character(col)) {
        stop("Provide a character vector indicating which colors to alternate!")
    }

    if (missing(chrlabs)) {
        chrlabs = NULL
    }
    if (missing(suggestiveline)) {
        suggestiveline = -log10(1e-05)
    } else if (!is.numeric(suggestiveline)) {
        stop("Provide a numeric value for suggestiveline!")
    }

    if (missing(genomewideline)) {
        genomewideline = -log10(5e-08)
    } else if (!is.numeric(genomewideline)) {
        stop("Provide a numeric value for genomewideline!")
    }
    if (missing(highlight)) {
        highlight = NULL
    }

    if (missing(logp)) {
        logp = TRUE
    } else if (!is.logical(logp)) {
        stop("Provide a logical value for logp!")
    }

    if (missing(annotatePval)) {
        annotatePval = NULL
    }

    if (missing(annotateTop)) {
        annotateTop = TRUE
    } else if (!is.logical(annotateTop)) {
        stop("Provide a logical value for annotateTop!")
    }
    # Create a new data.frame with columns called CHR, BP, and P.
    d = data.frame(CHR = as.numeric(gsub("[[:alpha:]]", "",
                as.data.frame(rowRanges(object))$seqnames)),
                BP = as.data.frame(rowRanges(object))$start,
                P = metadata(object)$DMCHMM$pvalues,
                NameBP = as.data.frame(rowRanges(object))$start -
                    min(as.data.frame(rowRanges(object))$start) + 1)
    # If the input data frame has a SNP column, add it to the new data
    # frame you're creating.
    if (!is.null(metadata(object)$DMCHMM$snp))
        d = transform(d, SNP = metadata(object)$DMCHMM$snp)

    # Set positions, ticks, and labels for plotting Sort and keep only
    # values where is numeric. d <- subset(d[order(d$CHR, d$BP), ], (P>0 &
    # P<=1 & is.numeric(P)))
    d <- subset(d, (is.numeric(CHR) & is.numeric(BP) & is.numeric(P) &
        is.numeric(NameBP)))
    d <- d[order(d$CHR, d$BP), ]
    if (logp) {
        d$logp <- -log10(d$P)
    } else {
        d$logp <- d$P
    }
    d$pos = NA

    # Fixes the bug where one chromosome is missing by adding a sequential
    # index column.
    d$index = NA

    udCHR <- unique(d$CHR)
    i <- seq_along(udCHR)
    idx <- match(d$CHR, udCHR)
    d[idx, ]$index <- i[idx]

    # This section sets up positions and ticks. Ticks should be placed in
    # the middle of a chromosome. The a new pos column is added that keeps
    # a running sum of the positions of each successive chromsome. For
    # example: chr bp pos 1 1 1 1 2 2 2 1 3 2 2 4 3 1 5
    nchr = length(unique(d$CHR))
    if (nchr == 1) {
        ## For a single chromosome Uncomment the next two linex to plot single
        ## chr results in Mb options(scipen=999) d$pos=d$BP/1e6
        d$pos = d$BP
        ticks = floor(length(d$pos))/2 + 1
        xlabel = paste("Chromosome", unique(d$CHR), "position")
        labs = ticks
    } else {
        ## For multiple chromosomes
        lastbase = 0
        ticks = NULL
        for (i in unique(d$index)) {
            if (i == 1) {
                d[d$index == i, ]$pos = d[d$index == i, ]$BP
            } else {
                lastbase = lastbase + tail(subset(d, index == i - 1)$BP, 1)
                d[d$index == i, ]$pos = d[d$index == i, ]$BP + lastbase
            }
        # Old way: assumes SNPs evenly distributed ticks=c(ticks,
        # d[d$index==i,]$pos[floor(length(d[d$index==i, ]$pos)/2)+1]) New way:
        # doesn't make that assumption
            ticks = c(ticks, (min(d[d$index == i, ]$pos) + max(d[d$index ==
                i, ]$pos))/2 + 1)
        }
        xlabel = "Chromosome"
        # labs = append(unique(d$CHR),'') I forgot what this was here for... if
        # seems to work, remove.
        labs <- unique(d$CHR)
    }

    # Initialize plot
    xmax = ceiling(max(d$pos) * 1.03)
    xmin = floor(max(d$pos) * -0.03)

    def_args <- list(xaxt = "n", bty = "n", xaxs = "i", yaxs = "i", las = 1,
        pch = 20, xlim = c(xmin, xmax), ylim = c(0, ceiling(max(d$logp))),
        xlab = xlabel, ylab = expression(-log[10](italic(p))))
    # Next, get a list of ... arguments dotargs <-
    # as.list(match.call())[-1L]
    dotargs <- list(...)
    # And call the plot function passing NA, your ... arguments, and the
    # default arguments that were not defined in the ... arguments.
    do.call("plot", c(NA, dotargs,
                        def_args[!names(def_args) %in% names(dotargs)]))

    # If manually specifying chromosome labels, ensure a character vector
    # and number of labels matches number chrs.
    if (!is.null(chrlabs)) {
        if (is.character(chrlabs)) {
            if (length(chrlabs) == length(labs)) {
                labs <- chrlabs
            } else {
                warning("You're trying to specify chromosome labels but
                        the number of labels != number of chromosomes.")
            }
        } else {
            warning("If you're trying to specify chromosome labels,
                    chrlabs must be a character vector")
        }
    }

    # Add an axis. If single chromosome, ticks and labels automatic.
    if (nchr == 1) {
        axis(1, ...)
    } else {
        # if multiple chrs, use the ticks and labels you created above.
        axis(1, at = ticks, labels = labs, ...)
    }

    # Create a vector of alternatiting colors
    col = rep(col, max(d$CHR))

    # Add points to the plot
    if (nchr == 1) {
        with(d, points(pos, logp, pch = 20, col = col[1], ...))
    } else {
        # if multiple chromosomes, need to alternate colors and increase the
        # color index (icol) each chr.
        icol = 1
        for (i in unique(d$index)) {
            with(d[d$index == unique(d$index)[i], ], points(pos, logp,
                col = col[icol], pch = 20, ...))
            icol = icol + 1
        }
    }

    # Add suggestive and genomewide lines
    if (suggestiveline)
        abline(h = suggestiveline, col = "blue")
    if (genomewideline)
        abline(h = genomewideline, col = "red")

    # Highlight snps from a character vector
    if (!is.null(highlight)) {
        if (any(!(highlight %in% d$SNP)))
            warning("You're trying to highlight
        SNPs that don't exist in your results.")
        d.highlight = d[which(d$SNP %in% highlight), ]
        with(d.highlight, points(pos, logp, col = "green3", pch = 20, ...))
    }

    # Highlight top SNPs
    if (!is.null(annotatePval)) {
        # extract top SNPs at given p-val
        topHits = subset(d, P <= annotatePval)
        par(xpd = TRUE)
        # annotate these SNPs
        if (annotateTop == FALSE) {
            with(subset(d, P <= annotatePval), textxy(pos, -log10(P),
                    offset = 0.625, labs = topHits$SNP, cex = 0.45), ...)
        } else {
            # could try alternative, annotate top SNP of each sig chr
            topHits <- topHits[order(topHits$P), ]
            topSNPs <- NULL

            topSNPs <- lapply(unique(topHits$CHR), function(i) {
                chrSNPs <- topHits[topHits$CHR == i, ]
            })
            topSNPs <- do.call(rbind, topSNPs)
            textxy(topSNPs$pos, -log10(topSNPs$P), offset = 0.625,
                    labs = topSNPs$SNP, cex = 0.5, ...)
        }
    }
    par(xpd = FALSE)
}

#' @rdname manhattanDMCs-method
#' @aliases manhattanDMCs-method manhattanDMCs
setMethod("manhattanDMCs", signature(object = "BSDMCs", col = "ANY",
    chrlabs = "ANY", suggestiveline = "ANY", genomewideline = "ANY",
    highlight = "ANY", logp = "ANY", annotatePval = "ANY", annotateTop = "ANY"),
    .manhattanDMCs)

