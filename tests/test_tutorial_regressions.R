# Exercise the functions actually printed in the tutorial, without its plots.
load_functions <- function(path, wanted) {
  lines <- readLines(path); inside <- FALSE; code <- character()
  for (line in lines) {
    if (grepl('^```\\{r', line)) { inside <- TRUE; next }
    if (inside && grepl('^```', line)) { inside <- FALSE; next }
    if (inside) code <- c(code, line)
  }
  env <- new.env(parent = globalenv())
  for (expr in parse(text = code)) {
    if (is.call(expr) && identical(expr[[1]], as.name('<-')) && is.symbol(expr[[2]]) &&
        as.character(expr[[2]]) %in% wanted) eval(expr, envir = env)
  }
  env
}
mlp <- load_functions('tutorials/ai-ml-foundations-and-applications/perceptron-to-deep-learning-historical-r-implementation/index.qmd', c('sigmoid','mlp_train_xor'))
fit <- mlp$mlp_train_xor()
stopifnot(identical(as.numeric(fit$predictions > 0.5), c(0,1,1,0)),
          tail(fit$loss_history,1) < head(fit$loss_history,1),
          all(is.finite(fit$loss_history)))
auction <- load_functions('tutorials/case-studies/spectrum-auctions-policy/index.qmd', 'package_value')
auction$base_values <- matrix(1:6,nrow=1); auction$comp_bonus <- 10
stopifnot(auction$package_value(integer(),1)==0,
          auction$package_value(1,1)==1,
          auction$package_value(c(1,2),1)==13,
          auction$package_value(c(1,3),1)==4)
cat('XOR predictions/loss and empty/single/adjacent/nonadjacent package values passed\n')

sh <- load_functions('tutorials/cryptography-and-gt/secure-multi-party-computation/index.qmd', c('field_check','mod_power','shamir_share','shamir_reconstruct'))
sh$tibble <- tibble::tibble
for (seed in 1:20) {
  set.seed(seed); x <- sh$shamir_share(1234, 5, 3)
  for (indices in combn(5,3,simplify=FALSE))
    stopifnot(sh$shamir_reconstruct(x$shares[indices,]) == 1234)
}
for (d in 1:2088) stopifnot((d * sh$mod_power(d,2087,2089)) %% 2089 == 1)
stopifnot(inherits(try(sh$shamir_share(1,5,3,prime=15),silent=TRUE),'try-error'),
          inherits(try(sh$shamir_reconstruct(data.frame(x=c(1,1),y=c(2,3))),silent=TRUE),'try-error'))
cat('200 threshold reconstructions and 2088 modular inverses passed\n')

folk <- load_functions('tutorials/foundations/folk-theorem-perfect-monitoring/index.qmd', 'public_grim_threshold')
stopifnot(all.equal(folk$public_grim_threshold(c(1,2,3),5,3,1),c(1,2/3,1/2)),
          all(diff(folk$public_grim_threshold(seq(1.01,3,by=.01),5,3,1))<0))
source('R/theme_publication.R')
p <- ggplot2::ggplot(data.frame(x=1:2,y=2:3),ggplot2::aes(x,y))+ggplot2::geom_point()
root <- tempfile('nested-figure-');stem <- file.path(root,'nested','plot')
save_pub_fig(p,stem,width=2,height=2,dpi=72)
stopifnot(all(file.exists(paste0(stem,c('.pdf','.png')))))
unlink(root,recursive=TRUE)
cat('Public grim-trigger incentive thresholds and nested figure export passed\n')

clarke <- load_functions('tutorials/foundations/revelation-principle/index.qmd', 'clarke_public_payments')
v <- matrix(c(6,5, 4,3, 11,0, 5,5),ncol=2,byrow=TRUE)
stopifnot(identical(clarke$clarke_public_payments(v,10),
                    matrix(c(5,4,0,0,10,0,5,5),ncol=2,byrow=TRUE)))
# A sole beneficiary pays the cost when the project is built.
stopifnot(identical(clarke$clarke_public_payments(matrix(c(12,8),ncol=1),10),
                    matrix(c(10,0),ncol=1)))
cat('Clarke public-project charges: pivotal, nonpivotal, no build, tie, one agent passed\n')

el <- load_functions('tutorials/classical-games/el-farol-bar-problem/index.qmd','score_forecasts')
old <- matrix(c(1,2,3,4),2,byrow=TRUE)
pred <- matrix(c(10,50,20,40),2,byrow=TRUE)
stopifnot(identical(el$score_forecasts(old,pred,30),matrix(c(401,402,103,104),2,byrow=TRUE)),
          identical(pred,matrix(c(10,50,20,40),2,byrow=TRUE)))
cat('Recorded forecast scoring matches independently computed errors without changing predictions\n')

mat <- load_functions('tutorials/linear-algebra-matrix/matrix-games-and-linear-algebra/index.qmd','solve_2x2_bimatrix')
A <- matrix(c(1,-1,-1,1),2,byrow=TRUE)
z <- mat$solve_2x2_bimatrix(A,-A)
stopifnot(identical(z$x,c(.5,.5)),identical(z$y,c(.5,.5)),z$v1==0,z$v2==0)
A <- matrix(c(3,0,0,2),2,byrow=TRUE);B <- matrix(c(2,0,0,3),2,byrow=TRUE)
z <- mat$solve_2x2_bimatrix(A,B)
stopifnot(all.equal(z$x,c(.6,.4)),all.equal(z$y,c(.4,.6)),
          is.null(mat$solve_2x2_bimatrix(matrix(0,2,2),matrix(0,2,2))$x),
          inherits(try(mat$solve_2x2_bimatrix(matrix(1,2,1),B),silent=TRUE),'try-error'))
cat('Interior bimatrix examples, degenerate result and invalid shape passed\n')

mp <- load_functions('tutorials/cryptography-and-gt/secure-multiparty-computation/index.qmd',c('field_check','mod_inv','shamir_share','shamir_reconstruct'))
for (seed in 1:20) {
  set.seed(seed);z <- mp$shamir_share(42,5,2,997)
  for (ix in combn(5,3,simplify=FALSE)) stopifnot(mp$shamir_reconstruct(ix,z$shares[ix],997)==42)
}
for (i in 1:996) stopifnot((i*mp$mod_inv(i,997))%%997==1)
stopifnot(inherits(try(mp$mod_inv(0,997),silent=TRUE),'try-error'),
          inherits(try(mp$shamir_reconstruct(c(1,1),c(2,2),997),silent=TRUE),'try-error'))
# Regression for the formerly excluded zero coefficient.
set.seed(42)
coefficients <- replicate(200,mp$shamir_share(0,4,1,5)$coeffs[2])
stopifnot(setequal(coefficients,0:4))
cat('Second secret-sharing example: 200 reconstructions, 996 inverses and invalid shares passed\n')
mo <- load_functions('tutorials/evolutionary-gt/moran-process-finite-populations/index.qmd','fixation_prob_analytical')
for (k in 0:20) stopifnot(abs(mo$fixation_prob_analytical(matrix(0,2,2),20,w=0,initial_k=k)-k/20)<1e-12)
A <- matrix(c(2,2,1,1),2,byrow=TRUE)
for (k in 1:19) stopifnot(abs(mo$fixation_prob_analytical(A,20,w=1,initial_k=k)-(1-.5^k)/(1-.5^20))<1e-12)
stopifnot(is.finite(mo$fixation_prob_analytical(matrix(c(1,1,2,2),2,byrow=TRUE),2000,w=1)))
cat('Moran fixation boundaries, neutral drift, constant fitness and large-population stability passed\n')

piv <- load_functions('tutorials/mechanism-design/mechanism-design-intro/index.qmd','pivotal_mechanism')
v <- c(15,12,8,7,5,4,3,2);z <- piv$pivotal_mechanism(v,50)
stopifnot(identical(z$utilities,c(6,6,6,6,5,4,3,2)),sum(z$payments)-50 == -32,
          identical(piv$pivotal_mechanism(c(-10,12),10)$payments,c(2,0)))
for (i in seq_along(v)) for (report in -20:70) {
  fake <- v;fake[i] <- report;res <- piv$pivotal_mechanism(fake,50)
  true_utility <- (if(res$provide) v[i] else 0)-res$payments[i]
  stopifnot(true_utility <= z$utilities[i]+1e-10)
}
cat('Pivotal utilities, budget deficit, negative pivotal type and 728 deviations passed\n')

nr <- load_functions('tutorials/ml-and-gt/no-regret-learning-games/index.qmd',c('mwu_update','exp3_update','ftrl_entropic','run_algorithm'))
stopifnot(all.equal(nr$mwu_update(c(1,2,3),c(-1,0,1),.1),c(.9,2,3.3)/6.2),
          all.equal(nr$exp3_update(rep(1,3),1,1,3,.1),c(exp(.1),1,1)/(exp(.1)+2)),
          inherits(try(nr$mwu_update(rep(1,3),c(-1,0,1),2),silent=TRUE),'try-error'))
A <- matrix(c(0,-1,1,1,0,-1,-1,1,0),3,byrow=TRUE)
for (seed in 1:2) for (algo in c('MWU','Exp3','FTRL')) {
  set.seed(seed);res <- nr$run_algorithm(algo,1000,A)
  stopifnot(nrow(res)==1000,all(is.finite(res$per_round_regret)),all(abs(res$per_round_regret)<=2+1e-12))
}
cat('Normalized learning updates and six 1000-round RPS learning runs passed\n')

pr <- load_functions('tutorials/reproducibility-open-science/preregistration-game-experiments/index.qmd','simulate_pgg')
set.seed(42);paired <- pr$simulate_pgg(1000,n_players=4,n_rounds=5,treat_effect=0,paired=TRUE)
set.seed(42);independent <- pr$simulate_pgg(1000,n_players=4,n_rounds=5,treat_effect=0,paired=FALSE)
stopifnot(nrow(paired)==40000,all(table(paired$condition,paired$group)==20),
          all(paired$contribution>=0 & paired$contribution<=20),
          length(unique(independent$group))==2000,
          inherits(try(pr$simulate_pgg(5,icc=1),silent=TRUE),'try-error'))
pm <- aggregate(contribution~condition+group,paired,mean)
pm <- reshape(pm,idvar='group',timevar='condition',direction='wide')
im <- aggregate(contribution~condition+group,independent,mean)
stopifnot(var(pm$contribution.treatment-pm$contribution.control) <
          .25*(var(im$contribution[im$condition=='control'])+var(im$contribution[im$condition=='treatment'])))
cat('Vectorized clustered simulation: dimensions, clipping, matched groups and shared-effect variance passed\n')

mc <- load_functions('tutorials/simulations/monte-carlo-game-equilibria/index.qmd','make_beta_bid')
for (n in c(2,3,5)) {
  uniform_bid <- mc$make_beta_bid(n,1,1)
  v <- c(0,1e-5,.001,seq(.01,1,length.out=101))
  stopifnot(max(abs(uniform_bid(v)-(n-1)*v/n))<1e-7)
  beta_bid <- mc$make_beta_bid(n)
  direct <- vapply(v[-1],function(x) x-integrate(function(t)
    (pbeta(t,2,5)/pbeta(x,2,5))^(n-1),0,x,rel.tol=1e-11)$value,0)
  stopifnot(max(abs(beta_bid(v[-1])-direct))<1e-7,
            all(diff(beta_bid(v))>=-1e-12), all(beta_bid(v)<=v),
            inherits(try(beta_bid(-.1),silent=TRUE),'try-error'))
}
cat('Auction interpolation agrees with uniform equilibrium and 309 adaptive Beta integrals to 1e-7\n')

gr <- load_functions('tutorials/time-series-econometrics/granger-causality-strategic/index.qmd','granger_test')
set.seed(190);x <- rnorm(150);y <- numeric(150)
for(i in 2:150) y[i] <- .4*y[i-1] + .7*x[i-1]+rnorm(1)
z <- gr$granger_test(y,x,p=1)
d <- data.frame(y=y[-1],yl=head(y,-1),xl=head(x,-1))
a <- anova(lm(y~yl,d),lm(y~yl+xl,d))
stopifnot(abs(z$F_stat-a$F[2])<1e-10,abs(z$p_value-a$`Pr(>F)`[2])<1e-12,
          z$df2==146,inherits(try(gr$granger_test(y,x[-1]),silent=TRUE),'try-error'),
          inherits(try(gr$granger_test(rep(1,30),rep(1,30)),silent=TRUE),'try-error'))
cat('Printed lag-exclusion test agrees with independent nested-model ANOVA; invalid/rank-deficient data rejected\n')
