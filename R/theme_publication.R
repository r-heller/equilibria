# theme_publication.R — publication-ready ggplot2 theme for #equilibria
# Okabe-Ito colorblind-safe palette throughout

#' Publication-ready ggplot2 theme
#'
#' @param base_size Base font size (default 12)
#' @param base_family Base font family
#' @return A ggplot2 theme object
theme_publication <- function(base_size = 12, base_family = "") {
  ggplot2::theme_minimal(base_size = base_size, base_family = base_family) +
    ggplot2::theme(
      # Text
      plot.title = ggplot2::element_text(size = base_size * 1.2, face = "bold", hjust = 0),
      plot.subtitle = ggplot2::element_text(size = base_size * 0.9, hjust = 0, color = "grey40"),
      plot.caption = ggplot2::element_text(size = base_size * 0.7, hjust = 1, color = "grey50"),

      # Axes
      axis.title = ggplot2::element_text(size = base_size * 0.9),
      axis.text = ggplot2::element_text(size = base_size * 0.8),
      axis.line = ggplot2::element_line(color = "grey30", linewidth = 0.3),
      axis.ticks = ggplot2::element_line(color = "grey30", linewidth = 0.3),

      # Panel
      panel.grid.major = ggplot2::element_line(color = "grey90", linewidth = 0.2),
      panel.grid.minor = ggplot2::element_blank(),
      panel.border = ggplot2::element_blank(),

      # Legend
      legend.position = "bottom",
      legend.title = ggplot2::element_text(size = base_size * 0.85, face = "bold"),
      legend.text = ggplot2::element_text(size = base_size * 0.8),
      legend.key.size = ggplot2::unit(0.8, "lines"),

      # Facets
      strip.text = ggplot2::element_text(size = base_size * 0.85, face = "bold"),
      strip.background = ggplot2::element_rect(fill = "grey95", color = NA),

      # Plot margins
      plot.margin = ggplot2::margin(10, 10, 10, 10)
    )
}

#' Okabe-Ito colorblind-safe discrete scale (fill)
scale_fill_okabe_ito <- function(...) {
  ggplot2::scale_fill_manual(values = c(
    "#E69F00", "#56B4E9", "#009E73", "#F0E442",
    "#0072B2", "#D55E00", "#CC79A7", "#999999"
  ), ...)
}

#' Okabe-Ito colorblind-safe discrete scale (colour)
scale_colour_okabe_ito <- function(...) {
  ggplot2::scale_colour_manual(values = c(
    "#E69F00", "#56B4E9", "#009E73", "#F0E442",
    "#0072B2", "#D55E00", "#CC79A7", "#999999"
  ), ...)
}

#' Save a publication-ready figure as both PDF and PNG at 300 dpi
#'
#' @param plot A ggplot2 object
#' @param filename Base filename (without extension)
#' @param width Width in inches (default 7)
#' @param height Height in inches (default 5)
#' @param dpi Resolution for PNG (default 300)
save_pub_fig <- function(plot, filename, width = 7, height = 5, dpi = 300) {
  ggplot2::ggsave(
    paste0(filename, ".pdf"), plot,
    width = width, height = height, device = "pdf"
  )
  ggplot2::ggsave(
    paste0(filename, ".png"), plot,
    width = width, height = height, dpi = dpi, device = "png"
  )
}
