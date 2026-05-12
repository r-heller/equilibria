# build_artifacts.R — generates artifacts/{graph.json, tutorials.csv,
# cooccurrence.csv} from frontmatter of every tutorial under tutorials/
# and shiny/tutorials/.
#
# graph.json shape matches the CTTIR/tutorials overview-page contract:
#   {
#     nodes: [{id, title, url, topic, tags, labels, date, year, summary}],
#     edges: [{source, target, weight}],
#     topics: [{id, label, color, blurb, order, count}],
#     tags:   [<unique tag strings>],
#     labels: [<unique label strings>],
#   }
#
# topics[] is sourced from _data/topics.yml (single source of truth).
# Nodes are id'd by "<topic-slug>/<article-slug>" so URLs survive renames.

suppressPackageStartupMessages({
  library(yaml)
  library(jsonlite)
})

`%||%` <- function(a, b) if (is.null(a) || length(a) == 0) b else a

load_topics <- function(path = "_data/topics.yml") {
  cfg <- yaml::read_yaml(path)
  lapply(cfg$topics, function(t) {
    list(
      id    = t$slug,
      label = t$display,
      color = t$color,
      blurb = t$blurb,
      order = as.integer(t$order)
    )
  })
}

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
    # Build id: <topic-dir>/<slug-dir>  (e.g. "bayesian-methods/global-games")
    parts <- strsplit(filepath, "/", fixed = TRUE)[[1]]
    if (length(parts) >= 4) {
      fm$.id  <- paste(parts[length(parts) - 2], parts[length(parts) - 1], sep = "/")
      fm$.url <- sub("/index\\.qmd$", "/", filepath)
      fm$.url <- sub("\\.qmd$", ".html", fm$.url)
    }
  }
  fm
}

build_artifacts <- function(output_dir = "artifacts") {
  dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)

  topics <- load_topics()
  topic_ids <- vapply(topics, function(t) t$id, character(1))

  files <- list.files(
    c("tutorials", "shiny/tutorials"),
    pattern = "\\.qmd$", recursive = TRUE, full.names = TRUE
  )
  files <- files[!grepl("/_template/", files, fixed = TRUE)]
  files <- files[grepl("/[^/]+/[^/]+/index\\.qmd$", files)]

  if (length(files) == 0) {
    writeLines("{\"nodes\":[],\"edges\":[],\"topics\":[],\"tags\":[],\"labels\":[]}",
               file.path(output_dir, "graph.json"))
    writeLines("id,title,url,topic,tags,labels,date", file.path(output_dir, "tutorials.csv"))
    writeLines("tag1,tag2,count", file.path(output_dir, "cooccurrence.csv"))
    return(invisible(NULL))
  }

  fms <- lapply(files, extract_frontmatter)
  fms <- Filter(function(x) !is.null(x) && !is.null(x$.id), fms)

  # Nodes
  nodes <- lapply(fms, function(fm) {
    cats   <- fm$categories %||% list()
    topic  <- if (length(cats) > 0) cats[[1]] else ""
    tags   <- if (length(cats) > 1) as.list(cats[-1]) else list()
    labels <- fm$labels %||% list()
    date   <- as.character(fm$date %||% "")
    year   <- if (nchar(date) >= 4) suppressWarnings(as.integer(substr(date, 1, 4))) else NA_integer_
    list(
      id      = fm$.id,
      title   = fm$title %||% "",
      url     = fm$.url %||% "",
      topic   = topic,
      tags    = as.list(unlist(tags)),
      labels  = as.list(unlist(labels)),
      date    = date,
      year    = if (is.na(year)) NA else year,
      summary = fm$description %||% ""
    )
  })

  # Edges: any shared tag (categories[1:]) or shared label produces an
  # edge. Weight = total count of shared items. This gives a dense
  # graph that clusters well via force-atlas2 — articles in the same
  # topic share their topic-slug tag, articles using the same method
  # share their method tag/label, etc. Topics[0] is the topic slug and
  # is excluded from "shared tag" counting because every article in a
  # topic shares it.
  edges <- list()
  if (length(fms) > 1) {
    # Pre-extract tag + label sets per article (faster than re-doing per pair)
    sets <- lapply(fms, function(fm) {
      cats <- unlist(fm$categories %||% character(0))
      tags <- if (length(cats) > 1) cats[-1] else character(0)
      labels <- unlist(fm$labels %||% character(0))
      list(
        topic = if (length(cats) > 0) cats[[1]] else "",
        tags = unique(tags),
        labels = unique(labels)
      )
    })
    for (i in 1:(length(fms) - 1)) {
      si <- sets[[i]]
      for (j in (i + 1):length(fms)) {
        sj <- sets[[j]]
        shared_tags   <- length(intersect(si$tags,   sj$tags))
        shared_labels <- length(intersect(si$labels, sj$labels))
        same_topic    <- as.integer(si$topic == sj$topic && nzchar(si$topic))
        # Heuristic weight: tags weighted higher than labels; same-topic
        # gives a small constant boost so clusters cohere visually.
        weight <- 2L * shared_tags + 1L * shared_labels + same_topic
        if (shared_tags + shared_labels >= 1) {
          edges[[length(edges) + 1]] <- list(
            source = fms[[i]]$.id,
            target = fms[[j]]$.id,
            weight = weight
          )
        }
      }
    }
  }

  # Topic counts (real, not advertised)
  topic_counts <- table(vapply(nodes, function(n) n$topic, character(1)))
  topics_with_counts <- lapply(topics, function(t) {
    t$count <- as.integer(topic_counts[t$id] %||% 0L)
    t
  })

  # Unique tags + labels (sorted, for chip rendering)
  all_tags   <- sort(unique(unlist(lapply(nodes, function(n) unlist(n$tags)))))
  all_labels <- sort(unique(unlist(lapply(nodes, function(n) unlist(n$labels)))))

  graph <- list(
    nodes  = nodes,
    edges  = edges,
    topics = topics_with_counts,
    tags   = as.list(all_tags),
    labels = as.list(all_labels)
  )

  writeLines(
    jsonlite::toJSON(graph, auto_unbox = TRUE, pretty = TRUE, null = "null", na = "null"),
    file.path(output_dir, "graph.json")
  )

  # ---- tutorials.csv (consumed by tutorials.qmd A-Z table + live-counts.html)
  rows <- lapply(seq_along(nodes), function(i) {
    n <- nodes[[i]]
    data.frame(
      id     = i,
      title  = n$title,
      url    = n$url,
      topic  = n$topic,
      tags   = paste(unlist(n$tags),   collapse = "; "),
      labels = paste(unlist(n$labels), collapse = "; "),
      date   = n$date,
      stringsAsFactors = FALSE
    )
  })
  tutorials_df <- do.call(rbind, rows)
  write.csv(tutorials_df, file.path(output_dir, "tutorials.csv"), row.names = FALSE)

  # ---- cooccurrence.csv (consumed by heatmap module)
  pair_counts <- list()
  for (n in nodes) {
    ts <- sort(unique(unlist(n$tags)))
    if (length(ts) < 2) next
    for (a in 1:(length(ts) - 1)) for (b in (a + 1):length(ts)) {
      k <- paste(ts[a], ts[b], sep = "\t")
      pair_counts[[k]] <- (pair_counts[[k]] %||% 0L) + 1L
    }
  }
  if (length(pair_counts) > 0) {
    pair_df <- do.call(rbind, lapply(names(pair_counts), function(k) {
      tt <- strsplit(k, "\t", fixed = TRUE)[[1]]
      data.frame(tag1 = tt[1], tag2 = tt[2], count = pair_counts[[k]], stringsAsFactors = FALSE)
    }))
    pair_df <- pair_df[order(-pair_df$count), ]
  } else {
    pair_df <- data.frame(tag1 = character(0), tag2 = character(0), count = integer(0))
  }
  write.csv(pair_df, file.path(output_dir, "cooccurrence.csv"), row.names = FALSE)

  message(sprintf(
    "Artifacts: %d nodes, %d edges, %d topics, %d tags, %d labels.",
    length(nodes), length(edges), length(topics_with_counts),
    length(all_tags), length(all_labels)
  ))
  invisible(NULL)
}

if (sys.nframe() == 0) build_artifacts()
