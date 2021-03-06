% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/AllGenerics.R, R/manhattanDMCs-method.R
\docType{methods}
\name{manhattanDMCs-method}
\alias{manhattanDMCs-method}
\alias{manhattanDMCs,BSDMCs-method}
\alias{manhattanDMCs}
\title{manhattanDMCs method}
\usage{
manhattanDMCs(object, col, chrlabs, suggestiveline, genomewideline,
  highlight, logp, annotatePval, annotateTop, ...)

\S4method{manhattanDMCs}{BSDMCs}(object, col, chrlabs, suggestiveline,
  genomewideline, highlight, logp, annotatePval, annotateTop, ...)
}
\arguments{
\item{object}{A \code{\link{BSData-class}} or \code{\link{BSDMCs-class}}
object}

\item{col}{A character vector indicating which colors to alternate.}

\item{chrlabs}{A character vector equal to the number of chromosomes
specifying the chromosome labels (e.g., \code{c(1:22, "X", "Y", "MT")}).}

\item{suggestiveline}{Where to draw a "suggestive" line. Default
-log10(1e-5). Set to FALSE to disable.}

\item{genomewideline}{Where to draw a "genome-wide sigificant" line. Default
-log10(5e-8). Set to FALSE to disable.}

\item{highlight}{A character vector of SNPs in your dataset to highlight.
These SNPs should all be in your dataset.}

\item{logp}{If TRUE, the -log10 of the p-value is plotted. It isn't very
useful to plot raw p-values, but plotting the raw value could be useful for
other genome-wide plots, for example, peak heights, bayes factors, test
statistics, other "scores," etc.}

\item{annotatePval}{If set, SNPs below this p-value will be annotated on the
plot.}

\item{annotateTop}{If TRUE, only annotates the top hit on each chromosome
that is below the annotatePval threshold.}

\item{...}{other possible parameters}
}
\value{
A Manhattan plot
}
\description{
Creates a Manhattan plot based on the p-values obtained
from \code{\link{findDMCs}} method
}
\examples{
set.seed(1980)
nr <- 150; nc <- 8
metht <- matrix(as.integer(runif(nr * nc, 0, 100)), nr)
methc <- matrix(rbinom(n=nr*nc,c(metht),prob = runif(nr*nc)),nr,nc)
r1 <- GRanges(rep('chr1', nr), IRanges(1:nr, width=1), strand='*')
names(r1) <- 1:nr
cd1 <- DataFrame(Group=rep(c('G1','G2'),each=nc/2),row.names=LETTERS[1:nc])
OBJ1 <- cBSData(rowRanges=r1,methReads=methc,totalReads=metht,colData=cd1)
OBJ2 <- methHMEM(OBJ1, MaxK=2, mc.cores=2)
OBJ3 <- methHMMCMC(OBJ2, mc.cores=2)
OBJ4 <- findDMCs(OBJ3, mc.cores=2)
manhattanDMCs(OBJ4)
}
\author{
Farhad Shokoohi <shokoohi@icloud.com>
}
\keyword{manhattan}
\keyword{visualization}
