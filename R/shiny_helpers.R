# shiny_helpers.R — shared utilities for #equilibria Shiny apps

#' Standard bslib theme matching the Quarto site
#' @return A bslib::bs_theme object
equilibria_theme <- function() {
  if (!requireNamespace("bslib", quietly = TRUE)) {
    stop("Package 'bslib' is required.")
  }
  bslib::bs_theme(
    version = 5,
    primary = "#0072B2",
    secondary = "#6c757d",
    success = "#009E73",
    info = "#56B4E9",
    warning = "#E69F00",
    danger = "#D55E00",
    base_font = bslib::font_google("Inter"),
    code_font = bslib::font_google("Fira Code")
  )
}
