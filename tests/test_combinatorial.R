# Execute the actual displayed auction example, then compare with exhaustive
# assignment enumeration (four items, four possible owners including unallocated).
lines <- readLines('tutorials/mechanism-design/combinatorial-auctions/index.qmd')
start <- which(lines=='#| label: combinatorial-auction')+1L
end <- which(seq_along(lines)>start & lines=='```')[1]-1L
e <- new.env(parent=globalenv());e$tibble <- tibble::tibble
invisible(capture.output(eval(parse(text=lines[start:end]),envir=e)))
stopifnot(abs(e$total_welfare-160)<1e-8,
          max(abs(e$vcg_payments-c(45,45,0)))<1e-8,
          length(e$exposure_results$t1_complete_ab)==1000L,
          all(e$exposure_results$t1_complete_ab <= (e$exposure_results$t1_items_won>=2)))
assignments <- as.matrix(expand.grid(rep(list(0:3),4)))
value <- function(owner,items) {
  base <- rbind(c(30,25,10,5),c(5,10,30,25),c(15,20,20,15))
  sum(base[owner,items]) +
    if (owner==1) 25*all(c(1,2)%in%items)+20*all(c(1,2,3)%in%items)
    else if (owner==2) 25*all(c(3,4)%in%items)+20*all(c(2,3,4)%in%items)
    else 10*(length(items)>=2)
}
values <- t(apply(assignments,1,function(a) vapply(1:3,function(i)value(i,which(a==i)),0)))
stopifnot(max(rowSums(values))==160)
for (i in 1:3) {
  outside <- max(rowSums(values[rowSums(assignments==i)==0,-i,drop=FALSE]))
  others_at_winner <- 160-e$allocation[[e$bidders[i]]]$value
  stopifnot(abs(e$vcg_payments[i]-(outside-others_at_winner))<1e-8)
}
cat('Actual auction example matches all 256 allocations and independent VCG payments\n')
