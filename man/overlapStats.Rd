\name{overlapStats}
\alias{combineOverlaps}
\alias{getBestOverlaps}
\alias{empiricalOverlaps}
\alias{mixedOverlaps}
\alias{summitOverlaps}

\title{Compute overlap statistics}
\description{Compute assorted statistics for overlaps between windows and regions in a Hits object.}

\usage{
combineOverlaps(overlaps, tab, o.weights=NULL, i.weights=NULL, ...)

getBestOverlaps(overlaps, tab, o.weights=NULL, i.weights=NULL, ...)

empiricalOverlaps(overlaps, tab, o.weights=NULL, i.weights=NULL, ...)

mixedOverlaps(overlaps, tab, o.weights=NULL, i.weights=NULL, ...)

summitOverlaps(overlaps, region.best, o.summit=NULL, i.summit=NULL)
}

\arguments{
\item{overlaps}{A \linkS4class{Hits} object produced by \code{\link{findOverlaps}}, 
containing overlaps between regions (query) and windows (subject).}
\item{tab}{A data.frame of (differential binding) statistics for each window.}
\item{o.weights}{A numeric vector specifying weights for each overlapped window.}
\item{i.weights}{A numeric vector specifying weights for each individual window.}
\item{...}{Other arguments to be passed to the wrapped functions.}
\item{region.best}{An integer vector specifying the window index that is the summit for each region.}
\item{o.summit}{A logical vector specifying the overlapped windows that are summits, 
or a corresponding integer vector of indices for such windows.}
\item{i.summit}{A logical vector specifying whether an individual window is a summit, 
or a corresponding integer vector of indices.}
}

\details{
These functions provide convenient wrappers around \code{\link{combineTests}}, \code{\link{getBestTest}}, 
\code{\link{empiricalFDR}}, \code{\link{mixedClusters}} and \code{\link{upweightSummit}} 
for handling overlaps between windows and arbitrary pre-specified regions.
They accept \linkS4class{Hits} objects produced by running \code{\link{findOverlaps}} 
between regions (as the query) and windows (as the subject).
Each set of windows overlapping a region is defined as a cluster to compute various statistics.

A wrapper is necessary as a window may overlap multiple regions.
If so, the multiple instances of that window are defined as distinct \dQuote{overlapped} windows, 
where each overlapped window is assigned to a different region.
Each overlapped window is represented by a separate entry of \code{overlaps}.
In contrast, the \dQuote{individual} window just refers to the window itself, regardless of what it overlaps.
This is represented by each row of the \linkS4class{RangedSummarizedExperiment} object and the \code{tab} derived from it.

The distinction between these two definitions is required to describe the weight arguments.
The \code{o.weights} argument refers to the weights for each region-window relationship.
This allows for different weights to be assigned to the same window in different regions.
The \code{i.weights} argument is the weight of the window itself, and is the same regardless of the region.
If both are specified, \code{o.weights} takes precedence.

For \code{summitOverlaps}, the \code{region.best} argument is designed to accept the \code{best} field in the output of \code{getBestOverlaps} (run with \code{by.pval=FALSE}).
This contains the index for the individual window that is the summit within each region.
In contrast, the \code{i.summit} argument indicates whether an individual window is a summit, e.g., from \code{\link{findMaxima}}.
The \code{o.summit} argument does the same for overlapped windows, though this has no obvious input within the \code{csaw} pipeline.
}

\value{
For \code{combineOverlaps}, \code{getBestOverlaps}, \code{empiricalOverlaps} and \code{mixedOverlaps}, 
a \linkS4class{DataFrame} is returned from their respective wrapped functions.
Each row of the DataFrame corresponds to a region, where regions without overlapped windows are assigned \code{NA} values.

For \code{summitOverlaps}, a numeric vector of weights is produced.
This can be used as \code{o.weight} in the other two functions.
}

\seealso{
\code{\link{combineTests}},
\code{\link{getBestTest}},
\code{\link{empiricalFDR}} and
\code{\link{upweightSummit}},
for the underlying functions.

\code{\link{findOverlaps}}, to generate the required \linkS4class{Hits} object.    
}

\author{
Aaron Lun
}

\examples{
bamFiles <- system.file("exdata", c("rep1.bam", "rep2.bam"), package="csaw")
data <- windowCounts(bamFiles, width=1, filter=1)
of.interest <- GRanges(c('chrA', 'chrA', 'chrB', 'chrC'), 
    IRanges(c(1, 500, 100, 1000), c(200, 1000, 700, 1500)))

# Making some mock results.
N <- nrow(data)
mock <- data.frame(logFC=rnorm(N), PValue=runif(N), logCPM=rnorm(N))

olap <- findOverlaps(of.interest, rowRanges(data))
combineOverlaps(olap, mock)
getBestOverlaps(olap, mock)
empiricalOverlaps(olap, mock)

# See what happens when you don't get many overlaps.
getBestOverlaps(olap[1,], mock)
combineOverlaps(olap[2,], mock)
empiricalOverlaps(olap[1,], mock)

# Weighting example, with window-specific weights.
window.weights <- runif(N) 
comb <- combineOverlaps(olap, mock, i.weight=window.weights)
comb <- getBestOverlaps(olap, mock, i.weight=window.weights)
comb <- empiricalOverlaps(olap, mock, i.weight=window.weights)

# Weighting example, with relation-specific weights.
best.by.ave <- getBestOverlaps(olap, mock, by.pval=FALSE)
w <- summitOverlaps(olap, region.best=best.by.ave$best)
head(w)
stopifnot(length(w)==length(olap))
combineOverlaps(olap, mock, o.weight=w)

# Running summitOverlaps for window-specific summits
# (output is still relation-specific weights, though).
is.summit <- findMaxima(rowRanges(data), range=100, metric=mock$logCPM)
w <- summitOverlaps(olap, i.summit=is.summit)
head(w)
}

\keyword{testing}
