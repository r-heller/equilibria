source('shiny-apps/01-two-by-two-nash-explorer/solver.R')
zero <- solve_nash_2x2(matrix(0,2,2),matrix(0,2,2))
stopifnot(length(zero)==1, zero[[1]]$type=='Family',
          identical(zero[[1]]$p_range,c(0,1)),identical(zero[[1]]$q_range,c(0,1)))
A <- matrix(c(1,-1,-1,1),2); mp <- solve_nash_2x2(A,-A)
stopifnot(length(mp)==1,mp[[1]]$p==0.5,mp[[1]]$q==0.5)
# Independent definition: no pure unilateral deviation improves payoff.
is_ne <- function(A,B,p,q) {
  u <- as.vector(A %*% c(q,1-q)); v <- as.vector(c(p,1-p) %*% B)
  max(u) - sum(c(p,1-p)*u) < 1e-8 && max(v)-sum(c(q,1-q)*v) < 1e-8
}
set.seed(42); checked <- 0L
for (i in 1:150) {
  A<-matrix(sample(-2:2,4,replace=TRUE),2); B<-matrix(sample(-2:2,4,replace=TRUE),2)
  eq<-solve_nash_2x2(A,B);stopifnot(length(eq)>0)
  for(e in eq) for(p in unique(c(e$p_range,e$p))) for(q in unique(c(e$q_range,e$q)))
    stopifnot(is_ne(A,B,p,q))
  for(p in seq(0,1,by=0.1)) for(q in seq(0,1,by=0.1)) {
    covered<-any(vapply(eq,function(e) p>=e$p_range[1]-1e-9 && p<=e$p_range[2]+1e-9 && q>=e$q_range[1]-1e-9 && q<=e$q_range[2]+1e-9,logical(1)))
    stopifnot(identical(covered,is_ne(A,B,p,q)));checked<-checked+1L
  }
}
stopifnot(inherits(try(solve_nash_2x2(matrix(Inf,2,2),B),silent=TRUE),'try-error'))
cat(checked,'independent grid membership checks plus every returned family endpoint passed\n')
