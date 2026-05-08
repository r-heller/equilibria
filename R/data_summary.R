# data_summary.R — utilities for summarizing datasets in tutorials

#' Print a clean data summary for tutorial articles
#' @param df A data frame
#' @param n Number of rows to preview (default 6)
data_summary <- function(df, n = 6) {
  cat("Dimensions:", nrow(df), "rows x", ncol(df), "columns\n\n")
  str(df, give.attr = FALSE)
  cat("\nFirst", n, "rows:\n")
  print(utils::head(df, n))
}
