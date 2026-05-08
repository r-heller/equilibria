# check_charcount.R — character count enforcement for #equilibria
# Every article must have >= 2500 prose characters (excluding YAML, code, refs).
# Used by CI workflow char-count.yml.

#' Count prose characters in a Quarto article
#'
#' Strips YAML frontmatter, fenced code blocks, inline code,
#' references div, link syntax, and headers before counting.
#'
#' @param filepath Path to a .qmd file
#' @return Integer: prose character count
count_prose_chars <- function(filepath) {
  lines <- readLines(filepath, warn = FALSE)
  text <- paste(lines, collapse = "\n")

  # Remove YAML frontmatter (between --- delimiters)
  text <- gsub("(?s)^---.*?---", "", text, perl = TRUE)

  # Remove fenced code blocks (```...```)
  text <- gsub("(?s)```.*?```", "", text, perl = TRUE)

  # Remove inline code (`...`)
  text <- gsub("`[^`]+`", "", text)

  # Remove references div (::: {#refs} ... :::)
  text <- gsub("(?s):::\\s*\\{#refs\\}.*?:::", "", text, perl = TRUE)

  # Remove div fences (::: {.*} and :::)
  text <- gsub(":::\\s*\\{[^}]*\\}", "", text)
  text <- gsub(":::", "", text)

  # Remove link syntax but keep link text: [text](url) -> text

  text <- gsub("\\[([^]]+)\\]\\([^)]+\\)", "\\1", text)

  # Remove header markers
  text <- gsub("^#{1,6}\\s*", "", text, perl = TRUE)

  # Remove HTML tags
  text <- gsub("<[^>]+>", "", text)

  # Remove Quarto shortcodes {{< ... >}}
  text <- gsub("\\{\\{<.*?>\\}\\}", "", text)

  # Remove excess whitespace
  text <- gsub("\\s+", " ", text)
  text <- trimws(text)

  nchar(text)
}

#' Check all articles meet the 2500-character minimum
#'
#' Scans tutorials/ and shiny/tutorials/ for .qmd files,
#' counts prose characters, and fails if any are below threshold.
#'
#' @param min_chars Minimum required prose characters (default 2500)
#' @param dirs Directories to scan
check_all_articles <- function(min_chars = 2500,
                                dirs = c("tutorials", "shiny/tutorials")) {
  files <- character(0)
  for (d in dirs) {
    if (dir.exists(d)) {
      found <- list.files(d, pattern = "\\.qmd$", recursive = TRUE, full.names = TRUE)
      # Exclude section index pages (but keep article index pages)
      found <- found[!grepl("/index\\.qmd$", found) | grepl("tutorials/[^/]+/[^/]+/index\\.qmd$", found)]
      # Exclude template directory
      found <- found[!grepl("/_template/", found)]
      files <- c(files, found)
    }
  }

  if (length(files) == 0) {
    message("No articles found to check.")
    return(invisible(NULL))
  }

  results <- data.frame(
    file = files,
    chars = vapply(files, count_prose_chars, integer(1)),
    stringsAsFactors = FALSE
  )
  results$pass <- results$chars >= min_chars

  failures <- results[!results$pass, ]

  if (nrow(failures) > 0) {
    message("FAILED: The following articles have fewer than ", min_chars, " prose characters:\n")
    for (i in seq_len(nrow(failures))) {
      message("  ", failures$file[i], " (", failures$chars[i], " chars)")
    }
    stop("Character count gate failed for ", nrow(failures), " article(s).")
  } else {
    message("PASSED: All ", nrow(results), " articles meet the ", min_chars, "-character minimum.")
  }

  invisible(results)
}
