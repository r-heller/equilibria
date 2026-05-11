# check_frontmatter.R — front-matter contract validator for #equilibria
# Hard-fails (stop()) on any violation. Called by .github/workflows/frontmatter-check.yml.

suppressPackageStartupMessages({
  library(yaml)
})

# Allowed kebab-case pattern: lowercase letters, digits, hyphens; no leading/trailing/double hyphens.
KEBAB_RE <- "^[a-z0-9]+(?:-[a-z0-9]+)*$"
ISO_DATE_RE <- "^\\d{4}-\\d{2}-\\d{2}$"

#' Load slug set from _data/topics.yml
load_topic_slugs <- function(path = "_data/topics.yml") {
  cfg <- yaml::read_yaml(path)
  vapply(cfg$topics, function(t) t$slug, character(1))
}

#' Extract front-matter from a .qmd file. Returns NULL on parse failure.
extract_frontmatter <- function(filepath) {
  lines <- readLines(filepath, warn = FALSE)
  if (length(lines) < 3 || lines[1] != "---") return(NULL)
  end <- which(lines[-1] == "---")[1] + 1
  if (is.na(end)) return(NULL)
  tryCatch(
    yaml::yaml.load(paste(lines[2:(end - 1)], collapse = "\n")),
    error = function(e) NULL
  )
}

#' Validate one article. Returns character vector of violations (empty if OK).
validate_article <- function(filepath, fm, topic_slugs) {
  violations <- character(0)
  v <- function(msg) violations <<- c(violations, msg)

  if (is.null(fm)) {
    v("front-matter could not be parsed")
    return(violations)
  }

  # Required scalar fields
  for (field in c("title", "description")) {
    val <- fm[[field]]
    if (is.null(val) || !is.character(val) || !nzchar(val)) {
      v(sprintf("missing or empty required field: %s", field))
    }
  }

  # date — required, ISO YYYY-MM-DD
  date_val <- fm$date
  if (is.null(date_val)) {
    v("missing required field: date")
  } else {
    date_str <- as.character(date_val)
    if (!grepl(ISO_DATE_RE, date_str, perl = TRUE)) {
      v(sprintf("date must be ISO YYYY-MM-DD: '%s'", date_str))
    }
  }

  # categories — required, non-empty, [0] must match a topic slug
  cats <- fm$categories
  if (is.null(cats) || length(cats) == 0) {
    v("missing or empty categories[]")
  } else {
    if (!(cats[[1]] %in% topic_slugs)) {
      v(sprintf("categories[0] '%s' not in _data/topics.yml slugs", cats[[1]]))
    }
    # remaining entries must be kebab-case
    if (length(cats) > 1) {
      for (i in 2:length(cats)) {
        if (!grepl(KEBAB_RE, cats[[i]], perl = TRUE)) {
          v(sprintf("categories[%d] '%s' must be kebab-case lowercase", i - 1, cats[[i]]))
        }
      }
    }
  }

  # labels — optional, but if present must all be kebab-case
  labels <- fm$labels
  if (!is.null(labels)) {
    for (i in seq_along(labels)) {
      if (!grepl(KEBAB_RE, labels[[i]], perl = TRUE)) {
        v(sprintf("labels[%d] '%s' must be kebab-case lowercase", i - 1, labels[[i]]))
      }
    }
  }

  violations
}

#' Walk corpus and validate. Skip _template/ and section index pages.
check_all <- function() {
  if (!file.exists("_data/topics.yml")) {
    stop("_data/topics.yml not found; cannot validate.")
  }
  topic_slugs <- load_topic_slugs()

  files <- list.files(
    "tutorials",
    pattern = "\\.qmd$", recursive = TRUE, full.names = TRUE
  )
  # Exclude template and bare section index pages (tutorials/<topic>/index.qmd)
  files <- files[!grepl("/_template/", files, fixed = TRUE)]
  files <- files[grepl("^tutorials/[^/]+/[^/]+/index\\.qmd$", files)]
  # Note: shiny/tutorials/ uses a separate 'shiny-tutorial' topic slug and
  # is intentionally out of scope for this validator.

  if (length(files) == 0) {
    message("No article files found.")
    return(invisible(NULL))
  }

  failures <- list()
  for (f in files) {
    fm <- extract_frontmatter(f)
    vs <- validate_article(f, fm, topic_slugs)
    if (length(vs) > 0) failures[[f]] <- vs
  }

  if (length(failures) > 0) {
    message("FAILED: front-matter violations in ", length(failures), " article(s):\n")
    for (f in names(failures)) {
      message("  ", f, ":")
      for (v in failures[[f]]) message("    - ", v)
    }
    stop("Front-matter check failed.")
  }
  message("PASSED: ", length(files), " article(s) validated.")
  invisible(NULL)
}

if (sys.nframe() == 0) {
  check_all()
}
