# apis_helpers.R — utilities for public API access in #equilibria tutorials
# Handles rate limiting, caching, and error reporting.

#' Safe GET request with retry and caching
#' @param url The URL to fetch
#' @param max_retries Maximum number of retries (default 3)
#' @param cache_dir Cache directory (default tempdir())
#' @return Response content or NULL on failure
safe_api_get <- function(url, max_retries = 3, cache_dir = tempdir()) {
  if (!requireNamespace("httr2", quietly = TRUE)) {
    stop("Package 'httr2' is required.")
  }

  cache_file <- file.path(cache_dir, digest::digest(url, algo = "md5"))
  if (file.exists(cache_file)) {
    cache_age <- difftime(Sys.time(), file.mtime(cache_file), units = "hours")
    if (cache_age < 1) {
      return(readRDS(cache_file))
    }
  }

  for (i in seq_len(max_retries)) {
    resp <- tryCatch({
      httr2::request(url) |>
        httr2::req_timeout(30) |>
        httr2::req_retry(max_tries = 1) |>
        httr2::req_perform()
    }, error = function(e) NULL)

    if (!is.null(resp) && httr2::resp_status(resp) == 200) {
      content <- httr2::resp_body_string(resp)
      saveRDS(content, cache_file)
      return(content)
    }

    Sys.sleep(2^i)
  }

  warning("Failed to fetch: ", url)
  NULL
}
