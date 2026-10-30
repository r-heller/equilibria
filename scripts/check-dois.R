# A denial or outage is not evidence that a DOI is registered.
classify_handle <- function(status, payload, doi, exceptions = character()) {
  code <- if (is.list(payload) && length(payload$responseCode) == 1L)
    suppressWarnings(as.integer(payload$responseCode)) else NA_integer_
  if (identical(as.integer(status), 200L) && identical(code, 1L)) return('registered')
  missing <- status %in% c(404L,410L) ||
    (identical(as.integer(status),200L) && identical(code,100L))
  if (missing && doi %in% exceptions) return('documented-unregistered')
  if (missing) 'unregistered' else 'unknown'
}

check_dois <- function(file = 'references.bib') {
  lines <- readLines(file, warn = FALSE)
  lines <- grep('^\\s*doi\\s*=',lines,ignore.case=TRUE,value=TRUE)
  dois <- unique(trimws(gsub('.*=\\s*\\{?([^},]+)\\}?.*','\\1',lines)))
  exceptions <- '10.1016/C2009-0-20864-X'
  failures <- character()
  for (doi in dois[nzchar(dois)]) {
    response <- tryCatch(httr2::request(paste0('https://doi.org/api/handles/',doi)) |>
      httr2::req_timeout(15) |>
      httr2::req_error(is_error=function(resp) FALSE) |>
      httr2::req_perform(), error=function(e) NULL)
    status <- if (is.null(response)) 999L else httr2::resp_status(response)
    payload <- if (identical(status,200L)) tryCatch(httr2::resp_body_json(response),error=function(e) NULL) else NULL
    state <- classify_handle(status,payload,doi,exceptions)
    message(doi, ': ', state, ' (HTTP ',status,')')
    if (state %in% c('unknown','unregistered')) failures <- c(failures,doi)
  }
  if (length(failures)) stop(length(failures),' DOI(s) remain unverified: ',paste(failures,collapse=', '))
  message('Resolver checks passed; documented unregistered exceptions remain unverified.')
}
if (sys.nframe() == 0L) check_dois()
