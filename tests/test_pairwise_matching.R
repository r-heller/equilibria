source('R/pairwise_matching.R')
# Independent small-graph oracle: either leave the first vertex unmatched,
# or pair it with each compatible remaining vertex.
brute_size <- function(mutual, remaining = seq_len(nrow(mutual))) {
  if (length(remaining) < 2L) return(0L)
  i <- remaining[1L]; rest <- remaining[-1L]
  best <- brute_size(mutual, rest)
  for (j in rest[mutual[i, rest]]) {
    best <- max(best, 1L + brute_size(mutual, setdiff(rest, j)))
  }
  best
}
check <- function(cmat) {
  matching <- find_pairwise_optimal(cmat)
  vertices <- unlist(matching)
  stopifnot(!anyDuplicated(vertices))
  for (edge in matching) stopifnot(cmat[edge[1], edge[2]], cmat[edge[2], edge[1]])
  stopifnot(length(matching) == brute_size(cmat & t(cmat)))
}
# The previous routine missed the edge when the first vertex was isolated.
x <- matrix(FALSE, 3, 3); x[2, 3] <- x[3, 2] <- TRUE
check(x)
set.seed(732)
for (n in 0:8) for (i in 1:12) check(matrix(runif(n*n) < 0.5, n, n))
for (bad in list(matrix(NA,2,2),matrix(2,2,2),matrix(TRUE,2,3),list())) {
  stopifnot(inherits(try(find_pairwise_optimal(bad), silent=TRUE),'try-error'))
}
cat('109 exact small-graph comparisons and invalid-input checks passed\n')
