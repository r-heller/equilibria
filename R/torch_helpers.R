# torch_helpers.R — R torch utilities for #equilibria deep learning tutorials

#' Check that torch is available and provide install instructions if not
check_torch <- function() {
  if (!requireNamespace("torch", quietly = TRUE)) {
    stop(
      "Package 'torch' is required for this tutorial.\n",
      "Install with: install.packages('torch')\n",
      "Then run: torch::install_torch()"
    )
  }
  if (!torch::torch_is_installed()) {
    stop("torch backend not installed. Run: torch::install_torch()")
  }
  invisible(TRUE)
}
