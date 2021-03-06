\name{mergeWindowsList}
\alias{mergeWindowsList}
\alias{findOverlapsList}

\title{Consolidate window sizes}
\description{Consolidate windows of different sizes into a common set of regions.}

\usage{
mergeWindowsList(ranges.list, tol, ...)

findOverlapsList(ranges.list, regions, ...)
}

\arguments{
\item{ranges.list}{A list of \linkS4class{RangedSummarizedExperiment} and/or \linkS4class{GRanges} objects.}
\item{tol}{An integer scalar specifying the tolerance to use in \code{\link{mergeWindows}}.}
\item{...}{For \code{mergeWindowsList}, further arguments to pass to \code{\link{mergeWindows}}.

For \code{findOverlapsList}, further arguments to pass to \code{\link{findOverlaps}}.}
\item{regions}{A \linkS4class{GRanges} object specifying reference regions of interest for overlapping with windows.}
}

\value{
\code{mergeWindowsList} returns a named list containing:
\describe{
\item{\code{ranges}:}{A \linkS4class{GRanges} object containing the concatenated intervals from all elements of \code{x}.
The element-wise metadata of this GRanges contains \code{origin}, 
an integer field specifying the index of \code{x} from which each interval was obtained.}
\item{\code{ids}:}{An integer vector of length equal to \code{ranges}. 
This specifies the cluster (i.e., entry of \code{merged}) to which each interval in \code{ranges} was assigned.}
\item{\code{regions}:}{A GRanges object containing the genomic coordinates of the clusters of merged windows,
as computed by \code{\link{mergeWindows}}.}
\item{\code{weights}:}{An numeric vector of length equal to \code{ranges}, specifying the weight of each interval.}
}

\code{findOverlapsList} returns a named list containing:
\describe{
\item{\code{ranges}:}{A \linkS4class{GRanges} object containing the concatenated intervals from all elements of \code{x}.
The element-wise metadata of this object contains the integer field \code{origin}, as described above.}
\item{\code{olap}:}{A \linkS4class{Hits} object containing the overlaps between \code{ref} (query) and \code{ranges} (subject).}
\item{\code{weights}:}{A numeric vector of length equal to \code{olap}, containing the weight of each overlap.}
}
}

\details{
DB analyses with \pkg{csaw} can be repeated using windows of different sizes to
provide comprehensive detection of DB at a range of spatial resolutions.
This function merges together those sets of windows of differing sizes, 
typically generated by multiple calls to \code{\link{windowCounts}} using different \code{width} values.
For \code{mergeWindowsList}, windows of all sizes are clustered together through \code{\link{mergeWindows}}.
For \code{findOverlapsList}, windows of all sizes are overlapped with \code{ref} using \code{\link{findOverlaps}}.

The aim is to pass the output of this function to \code{\link{combineTests}} or \code{\link{combineOverlaps}}.
This takes the statistical machinery used to combine p-values across windows for a cluster or reference region,
and recycles it to provide a rigorous method for consolidating statistics across multiple analyses with different window sizes.
However, it requires some care to balance the contribution of analyses with different window sizes to the combined p-value.
Otherwise, analyses with many small windows will dominate the calculation for each cluster or reference region.

To compensate for this effect, both functions weight each window's contribution to a cluster or region.
The weight is inversely proportional to the number of windows of the same size in the same cluster or region.
For \code{mergeWindowsList}, this yields a weight for each window,
while for \code{findOverlapsList}, this yields a weight for each overlap.
Application of those weights in \code{\link{combineTests}} and related functions ensures that the combined p-value 
is not dominated by numerous small windows within a cluster.
}

\seealso{
\code{\link{mergeWindows}}, for the functionality behind \code{mergeWindowsList}.

\code{\link{findOverlaps}}, for the functionality behind \code{findOverlapsList}.
}

\author{
Aaron Lun
}

\examples{
bamFiles <- system.file("exdata", c("rep1.bam", "rep2.bam"), package="csaw")
low <- windowCounts(bamFiles, width=1, filter=1)
med <- windowCounts(bamFiles, width=100, filter=1)
high <- windowCounts(bamFiles, width=500, filter=1)

cons <- mergeWindowsList(list(low, med, high), tol=100)
cons$ranges
cons$merged

of.interest <- GRanges(c('chrA', 'chrA', 'chrB', 'chrC'), 
    IRanges(c(1, 500, 100, 1000), c(200, 1000, 700, 1500)))
cons <- findOverlapsList(list(low, med, high), regions=of.interest)
cons$ranges
cons$olap
}

\keyword{clustering}
