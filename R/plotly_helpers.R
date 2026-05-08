# plotly_helpers.R — consistent interactive figure styling for #equilibria

#' Convert a ggplot2 object to a publication-styled plotly figure
#'
#' Wraps plotly::ggplotly() with consistent styling, removes
#' lasso/select buttons, and sets a clean modebar.
#'
#' @param gg A ggplot2 object
#' @param tooltip Tooltip fields (default c("text"))
#' @param ... Additional arguments passed to ggplotly
#' @return A plotly object
to_plotly_pub <- function(gg, tooltip = c("text"), ...) {
  if (!requireNamespace("plotly", quietly = TRUE)) {
    stop("Package 'plotly' is required. Install with install.packages('plotly').")
  }

  p <- plotly::ggplotly(gg, tooltip = tooltip, ...) |>
    plotly::config(
      displaylogo = FALSE,
      modeBarButtonsToRemove = c(
        "select2d", "lasso2d", "autoScale2d",
        "hoverClosestCartesian", "hoverCompareCartesian"
      )
    ) |>
    plotly::layout(
      font = list(family = "-apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif"),
      hoverlabel = list(
        bgcolor = "white",
        font = list(size = 12, color = "black")
      )
    )

  p
}
