# _common.R — shared setup for all #equilibria tutorials
# Source this at the top of every article: source(here::here("R", "_common.R"))

suppressPackageStartupMessages({
  library(tidyverse)
  library(here)
  library(scales)
  library(knitr)
  library(kableExtra)
})

# Source publication theme and helpers
source(here::here("R", "theme_publication.R"))
source(here::here("R", "plotly_helpers.R"))

# Global knitr options
knitr::opts_chunk$set(
  fig.align = "center",
  fig.retina = 2,
  out.width = "100%",
  dpi = 300,
  dev = c("png", "pdf"),
  fig.path = "figures/"
)

# Okabe-Ito colorblind-safe palette
okabe_ito <- c(
  "#E69F00", "#56B4E9", "#009E73", "#F0E442",
  "#0072B2", "#D55E00", "#CC79A7", "#999999"
)

# Set default ggplot theme
theme_set(theme_publication())
