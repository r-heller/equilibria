# Enumerate the three supports per player (Top/Bottom/both, Left/Right/both).
# For each support pair, best-response conditions are independent linear
# constraints on p and q. Their solution is a point, interval, or rectangle.
solve_nash_2x2 <- function(A, B, tolerance = 1e-10) {
  valid <- function(M) is.matrix(M) && is.numeric(M) &&
    identical(dim(M), c(2L, 2L)) && all(is.finite(M))
  if (!valid(A) || !valid(B)) stop("Payoffs must be finite numeric 2 by 2 matrices.")
  if (length(tolerance) != 1L || !is.finite(tolerance) || tolerance <= 0)
    stop("tolerance must be positive and finite.")
  # Positive rescaling preserves best responses and avoids overflow.
  An <- A / max(1, abs(A)); Bn <- B / max(1, abs(B))
  clip <- function(domain, at_zero, at_one, relation) {
    slope <- at_one - at_zero
    if (relation == "le") return(clip(domain, -at_zero, -at_one, "ge"))
    if (abs(slope) <= tolerance) {
      ok <- if (relation == "eq") abs(at_zero) <= tolerance else at_zero >= -tolerance
      return(if (ok) domain else NULL)
    }
    root <- -at_zero / slope
    if (relation == "eq") {
      if (root < domain[1] - tolerance || root > domain[2] + tolerance) return(NULL)
      return(rep(min(domain[2], max(domain[1], root)), 2))
    }
    if (slope > 0) domain[1] <- max(domain[1], root)
    else domain[2] <- min(domain[2], root)
    if (domain[1] > domain[2] + tolerance) return(NULL)
    # Clamp tiny roundoff at a boundary; never invent a point outside [0,1].
    domain <- pmin(1, pmax(0, domain))
    if (domain[1] > domain[2]) domain[] <- mean(domain)
    domain
  }
  domains <- list(c(1,1), c(0,0), c(0,1))
  relations <- c("ge", "le", "eq")
  rectangles <- list()
  for (i in 1:3) for (j in 1:3) {
    q <- clip(domains[[j]], An[1,2]-An[2,2], An[1,1]-An[2,1], relations[i])
    p <- clip(domains[[i]], Bn[2,1]-Bn[2,2], Bn[1,1]-Bn[1,2], relations[j])
    if (!is.null(p) && !is.null(q)) rectangles[[length(rectangles)+1L]] <- c(p,q)
  }
  # Remove contained sets, keeping one copy of equal sets.
  keep <- vapply(seq_along(rectangles), function(i) {
    !any(vapply(seq_along(rectangles), function(j) {
      if (i == j) return(FALSE)
      x <- rectangles[[i]]; y <- rectangles[[j]]
      inside <- x[1] >= y[1]-tolerance && x[2] <= y[2]+tolerance &&
        x[3] >= y[3]-tolerance && x[4] <= y[4]+tolerance
      inside && (any(abs(x-y) > tolerance) || j < i)
    }, logical(1)))
  }, logical(1))
  lapply(rectangles[keep], function(r) {
    p <- mean(r[1:2]); q <- mean(r[3:4])
    family <- r[2]-r[1] > tolerance || r[4]-r[3] > tolerance
    pure <- !family && p %in% c(0,1) && q %in% c(0,1)
    payoff <- function(M) sum(M * outer(c(p,1-p), c(q,1-q)))
    list(type = if (family) "Family" else if (pure) "Pure" else "Mixed",
         p = p, q = q, p_range = r[1:2], q_range = r[3:4],
         row_payoff = payoff(A), col_payoff = payoff(B),
         label = if (family) sprintf("p in [%.4g, %.4g], q in [%.4g, %.4g]",r[1],r[2],r[3],r[4])
           else sprintf("(%.4g, %.4g)",p,q))
  })
}
