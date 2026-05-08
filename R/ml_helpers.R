# ml_helpers.R — shared ML/AI utilities for #equilibria tutorials

#' Train/test split with optional stratification
#' @param df Data frame
#' @param prop Proportion for training (default 0.8)
#' @param strat_col Column name for stratification (optional)
#' @param seed Random seed
#' @return List with $train and $test data frames
train_test_split <- function(df, prop = 0.8, strat_col = NULL, seed = 42) {
  set.seed(seed)
  n <- nrow(df)

  if (is.null(strat_col)) {
    idx <- sample(n, floor(n * prop))
  } else {
    idx <- unlist(tapply(seq_len(n), df[[strat_col]], function(i) {
      sample(i, floor(length(i) * prop))
    }))
  }

  list(train = df[idx, ], test = df[-idx, ])
}
