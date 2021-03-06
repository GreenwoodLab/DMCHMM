% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/AllGenerics.R, R/methHMMCMC-method.R
\docType{methods}
\name{methHMMCMC-method}
\alias{methHMMCMC-method}
\alias{methHMMCMC,BSDMCs-method}
\alias{methHMMCMC}
\title{methHMMCMC method}
\usage{
methHMMCMC(object, useweight, nburn, nthin, nsamp, mc.cores)

\S4method{methHMMCMC}{BSDMCs}(object, useweight, nburn, nthin, nsamp,
  mc.cores)
}
\arguments{
\item{object}{A \code{\link{BSData-class}} or \code{\link{BSDMCs-class}}
object}

\item{useweight}{A logical value}

\item{nburn}{An integer value}

\item{nthin}{An integer value}

\item{nsamp}{An integer value}

\item{mc.cores}{An integer greater than 0}
}
\value{
\code{\link{BSDMCs-class}} object
}
\description{
Estimates the HMM methylation paths and the HMM order for
each sample using the MCMC algorithm
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
OBJ3
}
\author{
Farhad Shokoohi <shokoohi@icloud.com>
}
