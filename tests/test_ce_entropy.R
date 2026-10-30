# Load the functions displayed in the chapter, without running plots/examples.
lines<-readLines('tutorials/information-theory/entropy-correlated-equilibrium/index.qmd')
inside<-FALSE;code<-character()
for(line in lines){if(grepl('^```\\{r',line)){inside<-TRUE;next};if(inside&&grepl('^```',line)){inside<-FALSE;next};if(inside)code<-c(code,line)}
wanted<-c('build_ce_constraints','ce_vertices','ce_summary','solve_maxent_ce','solve_welfare_ce')
for(e in parse(text=code))if(is.call(e)&&identical(e[[1]],as.name('<-'))&&is.symbol(e[[2]])&&as.character(e[[2]])%in%wanted)eval(e)
# Direct conditional-obedience inequalities, independent of constraint builder.
obedient<-function(p,A,B){for(i in 1:2)if(sum(p[i,]*(A[i,]-A[3-i,])) < -1e-8)return(FALSE);for(j in 1:2)if(sum(p[,j]*(B[,j]-B[,3-j])) < -1e-8)return(FALSE);TRUE}
games<-list(list(matrix(0,2,2),matrix(0,2,2)),list(matrix(c(1,-1,-1,1),2),matrix(c(-1,1,1,-1),2)),list(matrix(c(3,5,0,1),2),matrix(c(3,0,5,1),2)),list(matrix(c(3,5,1,0),2),matrix(c(3,1,5,0),2)))
for(g in games){A<-g[[1]];B<-g[[2]];m<-solve_maxent_ce(A,B);w<-solve_welfare_ce(A,B)
 stopifnot(obedient(m$p,A,B),obedient(w$p,A,B),abs(sum(m$p)-1)<1e-8,min(m$p)>=-1e-9,w$welfare>=m$welfare-1e-7)
 # Exhaust all denominator-20 distributions, including the boundary.
 for(a in 0:20)for(b in 0:(20-a))for(c in 0:(20-a-b)){
  p<-matrix(c(a,b,c,20-a-b-c)/20,2,byrow=TRUE)
  if(obedient(p,A,B)){x<-p[p>0];stopifnot(-sum(x*log(x))<=m$entropy+1e-5,sum(p*(A+B))<=w$welfare+1e-8)}
 }
 swapped<-solve_maxent_ce(A[2:1,,drop=FALSE],B[2:1,,drop=FALSE]);stopifnot(max(abs(swapped$p[2:1,]-m$p))<1e-4)
}
stopifnot(max(abs(solve_maxent_ce(games[[1]][[1]],games[[1]][[2]])$p-.25))<1e-5)
stopifnot(abs(solve_maxent_ce(games[[3]][[1]],games[[3]][[2]])$p[2,2]-1)<1e-8)
cat('CE obedience, normalization, row permutation, uniform/unique equilibria and 7,084 independent grid comparisons passed\n')
