# Maximum-cardinality pairwise exchanges in a directed compatibility matrix.
# Each binary variable chooses one mutual edge. Vertex capacity is one.
find_pairwise_optimal <- function(cmat, timeout = 30L) {
  if (!is.matrix(cmat) || nrow(cmat) != ncol(cmat) ||
      !(is.logical(cmat) || is.numeric(cmat)) || anyNA(cmat) ||
      any(!cmat %in% c(0, 1))) {
    stop("cmat must be a square, non-missing 0/1 compatibility matrix.")
  }
  if (!is.numeric(timeout) || length(timeout) != 1L || !is.finite(timeout) ||
      timeout < 1 || timeout != floor(timeout) || timeout > .Machine$integer.max) {
    stop("timeout must be a positive integer number of seconds.")
  }
  mutual <- (cmat != 0) & t(cmat != 0)
  edges <- which(mutual & upper.tri(mutual), arr.ind = TRUE)
  if (!nrow(edges)) return(list())
  incidence <- matrix(0, nrow(cmat), nrow(edges))
  incidence[cbind(edges[, 1L], seq_len(nrow(edges)))] <- 1
  incidence[cbind(edges[, 2L], seq_len(nrow(edges)))] <- 1
  result <- lpSolve::lp("max", rep(1, nrow(edges)), incidence,
                        rep("<=", nrow(cmat)), rep(1, nrow(cmat)),
                        all.bin = TRUE, timeout = as.integer(timeout))
  if (result$status != 0L) {
    stop("Matching solver did not certify an optimum (status ", result$status,
         "); no optimal-matching claim is made.")
  }
  selected <- which(result$solution > 0.5)
  lapply(selected, function(i) as.integer(edges[i, ]))
}
