# build_artifacts.R — generates graph.json, tutorials.csv, cooccurrence.csv
# from frontmatter of all .qmd files under tutorials/ and shiny/tutorials/.
# Called by CI workflow artifacts-rebuild.yml on merge to main.

suppressPackageStartupMessages({
  library(yaml)
  library(jsonlite)
  library(tools)
})

#' Extract frontmatter from a .qmd file
#' @param filepath Path to .qmd
#' @return A list with frontmatter fields, or NULL
extract_frontmatter <- function(filepath) {
  lines <- readLines(filepath, warn = FALSE)
  if (length(lines) < 3 || lines[1] != "---") return(NULL)

  end <- which(lines[-1] == "---")[1] + 1
  if (is.na(end)) return(NULL)

  fm <- tryCatch(
    yaml::yaml.load(paste(lines[2:(end - 1)], collapse = "\n")),
    error = function(e) NULL
  )

  if (!is.null(fm)) {
    fm$.filepath <- filepath
    # Derive URL from filepath
    fm$.url <- gsub("^\\./", "", filepath)
    fm$.url <- gsub("/index\\.qmd$", "/", fm$.url)
    fm$.url <- gsub("\\.qmd$", ".html", fm$.url)
  }

  fm
}

#' Build all artifacts from tutorial frontmatter
#' @param output_dir Directory to write artifacts (default "artifacts")
build_artifacts <- function(output_dir = "artifacts") {
  dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)

  # Find all tutorial .qmd files
  files <- list.files(
    c("tutorials", "shiny/tutorials"),
    pattern = "\\.qmd$", recursive = TRUE, full.names = TRUE
  )

  # Exclude bare section index pages (tutorials/<section>/index.qmd with no article content)
  # but keep article index pages (tutorials/<section>/<slug>/index.qmd)
  article_files <- files[grepl("/[^/]+/[^/]+/", files)]

  if (length(article_files) == 0) {
    message("No articles found. Writing empty artifacts.")
    writeLines("{\"nodes\":[],\"edges\":[]}", file.path(output_dir, "graph.json"))
    writeLines("id,title,url,topic,tags,labels,date", file.path(output_dir, "tutorials.csv"))
    writeLines("tag1,tag2,count", file.path(output_dir, "cooccurrence.csv"))
    return(invisible(NULL))
  }

  fms <- lapply(article_files, extract_frontmatter)
  fms <- Filter(Negate(is.null), fms)

  # Build tutorials.csv
  rows <- lapply(seq_along(fms), function(i) {
    fm <- fms[[i]]
    data.frame(
      id = i,
      title = fm$title %||% "",
      url = fm$.url %||% "",
      topic = if (!is.null(fm$categories)) fm$categories[1] else "",
      tags = paste(fm$categories %||% character(0), collapse = "; "),
      labels = paste(fm$labels %||% character(0), collapse = "; "),
      date = as.character(fm$date %||% ""),
      stringsAsFactors = FALSE
    )
  })
  tutorials_df <- do.call(rbind, rows)
  write.csv(tutorials_df, file.path(output_dir, "tutorials.csv"), row.names = FALSE)

  # Build graph.json (nodes + edges based on shared tags)
  nodes <- lapply(seq_along(fms), function(i) {
    fm <- fms[[i]]
    list(
      id = i,
      title = fm$title %||% "",
      url = fm$.url %||% "",
      topic = if (!is.null(fm$categories)) fm$categories[1] else "",
      tags = fm$categories %||% list(),
      labels = fm$labels %||% list()
    )
  })

  # Edges: connect tutorials sharing >= 2 tags
  edges <- list()
  if (length(fms) > 1) {
    for (i in 1:(length(fms) - 1)) {
      tags_i <- fms[[i]]$categories %||% character(0)
      for (j in (i + 1):length(fms)) {
        tags_j <- fms[[j]]$categories %||% character(0)
        shared <- length(intersect(tags_i, tags_j))
        if (shared >= 2) {
          edges <- c(edges, list(list(source = i, target = j, weight = shared)))
        }
      }
    }
  }

  graph <- list(nodes = nodes, edges = edges)
  writeLines(
    jsonlite::toJSON(graph, auto_unbox = TRUE, pretty = TRUE),
    file.path(output_dir, "graph.json")
  )

  # Build cooccurrence.csv
  all_tags <- unlist(lapply(fms, function(fm) fm$categories %||% character(0)))
  unique_tags <- sort(unique(all_tags))

  if (length(unique_tags) > 1) {
    pairs <- expand.grid(tag1 = unique_tags, tag2 = unique_tags, stringsAsFactors = FALSE)
    pairs <- pairs[pairs$tag1 < pairs$tag2, ]

    pairs$count <- vapply(seq_len(nrow(pairs)), function(k) {
      sum(vapply(fms, function(fm) {
        cats <- fm$categories %||% character(0)
        pairs$tag1[k] %in% cats && pairs$tag2[k] %in% cats
      }, logical(1)))
    }, integer(1))

    pairs <- pairs[pairs$count > 0, ]
    pairs <- pairs[order(-pairs$count), ]
  } else {
    pairs <- data.frame(tag1 = character(0), tag2 = character(0), count = integer(0))
  }

  write.csv(pairs, file.path(output_dir, "cooccurrence.csv"), row.names = FALSE)

  message("Artifacts built: ", length(nodes), " nodes, ", length(edges), " edges, ",
          nrow(pairs), " tag co-occurrences.")
  invisible(list(graph = graph, tutorials = tutorials_df, cooccurrence = pairs))
}

# Run when called directly
if (sys.nframe() == 0) {
  build_artifacts()
}
