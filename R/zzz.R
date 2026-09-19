#' @importFrom cli cli_abort cli_warn cli_inform col_blue cli_progress_step
#' @importFrom stringr str_c str_glue str_extract str_squish str_replace_all str_remove_all
#' @importFrom httr2 req_url req_url_path req_url_query req_perform resp_body_json resp_body_raw
#' @importFrom checkmate assert_string assert_flag assert_character assert_directory
#' @importFrom rlang .data
#' @importFrom dplyr mutate select across
#' @importFrom tidyr matches all_of any_of everything
NULL

# Environment to store ----
.ctoclient_env <- new.env(parent = emptyenv())

# Get session ----
get_session <- function() {
  if (!cto_is_connected()) {
    cli_abort(c(
      x = "No active SurveyCTO session found.",
      i = "Please connect first using {.run ctoclient::cto_connect()}.",
      i = "Or set connection using {.run ctoclient::cto_set_connection()}."
    ))
  } else {
    session <- get(".session", envir = .ctoclient_env)
    if (!inherits(session, "cto_session")) {
      cli_abort(
        "Invalid session found. Please reconnect using {.run ctoclient::cto_connect()}."
      )
    }
    return(session)
  }
}

# Get verbose ----
get_verbose <- function() isTRUE(getOption("ctoclient.verbose", TRUE))

# Confirm Cookies ----
# TODO: Include in all non-API endpoints
confirm_cookies <- function() {
  session <- get_session()
  has_cookie <- !is.null(session$options$cookiefile)
  if (!has_cookie) {
    cli_abort(c(
      x = "For this function to work you need to use cookies.",
      i = "Please restart you connection with cookies {.run cto_connect(cookies = TRUE)}"
    ))
  }
  invisible(has_cookie)
}


# Drop NULL list ----
drop_nulls_recursive <- function(x) {
  if (!is.list(x)) {
    return(x)
  }
  x <- lapply(x, drop_nulls_recursive)
  Filter(function(z) !is.null(z) && !(is.list(z) && length(z) == 0), x)
}

# Assert URL-safe identifiers ----
# Rejects only the characters that can change the structure of a URL. This is
# deliberately not an allow-list: SurveyCTO does not document which characters
# a server or dataset name may contain, and none of the characters below are
# legal in a host name or in a SurveyCTO identifier.
assert_url_safe <- function(x, arg = "id") {
  checkmate::assert_character(x, min.chars = 1, any.missing = FALSE)
  unsafe <- grepl("[/\\\\?#@:[:space:]]", x)
  if (any(unsafe)) {
    cli_abort(
      c(
        "x" = "{.arg {arg}} must not contain {.val /}, {.val \\}, {.val ?},
               {.val #}, {.val @}, {.val :} or spaces.",
        "i" = "Problem with {.val {x[unsafe]}}."
      ),
      call = rlang::caller_env()
    )
  }
  invisible(TRUE)
}

# Form IDs, cached per server ----
# Returns `ids` together with whether they came from the cache, so the caller
# can tell a stale miss from a real one. The cache is keyed on the server
# name: switching connection with cto_set_connection() therefore cannot reuse
# another server's list. A session with no usable server name is never
# cached, so behaviour falls back to a plain request.
get_form_ids <- function(session, refresh = FALSE) {
  key <- session$server
  usable_key <- is.character(key) &&
    length(key) == 1L &&
    !is.na(key) &&
    nzchar(key)

  if (!usable_key) {
    return(list(
      ids = fetch_api_response(session, "api/v2/forms/ids"),
      cached = FALSE
    ))
  }

  cache <- .ctoclient_env$.form_ids
  if (!refresh && identical(cache$server, key) && length(cache$ids) > 0) {
    return(list(ids = cache$ids, cached = TRUE))
  }

  ids <- fetch_api_response(session, "api/v2/forms/ids")
  # Only a non-empty character vector is worth keeping.
  if (is.character(ids) && length(ids) > 0) {
    assign(".form_ids", list(server = key, ids = ids), envir = .ctoclient_env)
  }

  list(ids = ids, cached = FALSE)
}

# Assert form IDs ----
assert_form_id <- function(form_id, session = get_session()) {
  checkmate::assert_string(form_id)

  found <- get_form_ids(session)
  if (!(form_id %in% found$ids) && found$cached) {
    # The form may have been deployed since the list was cached. Refreshing
    # only after a cached miss keeps the number of requests at or below what
    # an uncached lookup would have made.
    found <- get_form_ids(session, refresh = TRUE)
  }

  if (!(form_id %in% found$ids)) {
    cli_abort(c(
      x = "There is no form with {.val {form_id}} ID",
      i = "Use {.run ctoclient::cto_form_ids()} to see available form IDs"
    ))
  }
  invisible(TRUE)
}


# Fetch API response ----
fetch_api_response <- function(req, url_path = NULL, file_path = NULL) {
  if (!is.null(url_path)) {
    req <- req_url_path(req, url_path)
  }

  if (is.null(file_path)) {
    req_perform(req) |>
      resp_body_json(
        simplifyVector = TRUE,
        flatten = TRUE
      )
  } else {
    req_perform(req) |>
      httr2::resp_body_raw() |>
      writeBin(file_path)
  }
}

# Fetch paginated json ----
fetch_paginated_response <- function(req, path, field = "data", max_pages = 1000) {
  resp <- fetch_api_response(req, path)
  out <- purrr::pluck(resp, field)
  cursor <- purrr::pluck(resp, "nextCursor")
  page <- 1L

  while (!is.null(cursor)) {
    if (page >= max_pages) {
      cli_warn("Stopped after {max_pages} pages of {.val {path}}.")
      break
    }
    req <- req_url_query(req, cursor = cursor)
    resp <- fetch_api_response(req, path)
    out <- dplyr::bind_rows(out, purrr::pluck(resp, field))

    previous <- cursor
    cursor <- purrr::pluck(resp, "nextCursor")
    # A server that keeps handing back the same cursor would loop forever.
    if (identical(cursor, previous)) {
      cli_warn("{.val {path}} returned the same cursor twice; stopping.")
      break
    }
    page <- page + 1L
  }

  return(out)
}

# Escape a label for use inside a Stata double-quoted string ----
# Stata expands $global and `local' references inside double quotes, so a
# label such as "Cost ($USD)" would otherwise come out as "Cost ()".
stata_escape_label <- function(x) {
  x |>
    str_remove_all("<[^<>]*>") |>
    str_replace_all(stringr::fixed("$"), "\\$") |>
    str_replace_all(stringr::fixed("`"), "'") |>
    str_replace_all('"', "'")
}

# Date and datetime variables of a form definition ----
# CompletionDate and SubmissionDate are review metadata: they never appear on
# the survey sheet but are always exported, so they join the datetime list.
form_datetime_vars <- function(name, type) {
  name <- str_squish(name)
  type <- str_squish(type)

  datetime <- unique(c(
    "CompletionDate",
    "SubmissionDate",
    name[grepl("^datetime$|^start$|^end$", type, TRUE)]
  ))
  date <- unique(name[grepl("^date$|^today$", type, TRUE)])

  list(
    datetime = datetime[!is.na(datetime)],
    date = date[!is.na(date)]
  )
}

# Structural fields of a form definition ----
# Rows that carry no data of their own. `begin repeat` is included because the
# export names its counter "<name>_count". Rows without a name, such as end
# group and end repeat, contribute nothing.
form_null_vars <- function(name, type) {
  name <- str_squish(name)
  type <- str_squish(type)

  is_null <- grepl(
    "^note|^begin[ _]group|^end[ _]group|^begin[ _]repeat|^end[ _]repeat",
    type,
    TRUE
  )
  is_begin_repeat <- grepl("^begin[ _]repeat", type, TRUE)
  stub <- ifelse(is_begin_repeat, paste0(name, "_count"), name)

  keep <- is_null & !is.na(name) & nzchar(name)
  sort(unique(stub[keep]))
}

# Stata block dropping structural fields that hold no data ----
# The candidates are split across numbered locals only to keep the lines
# readable. One loop walks those numbers and skips any that is empty. A
# variable is dropped only once Stata has confirmed it exists and that every
# value is missing.
build_null_block <- function(stubs, per_line = 6, max_locals = 100) {
  if (length(stubs) == 0) {
    return(character(0))
  }

  # Never declare more locals than the loop will read.
  per_line <- max(per_line, ceiling(length(stubs) / max_locals))
  chunks <- split(stubs, ceiling(seq_along(stubs) / per_line))

  declarations <- vapply(
    seq_along(chunks),
    function(i) {
      as.character(
        str_glue("\tlocal nullvars{i} {paste(chunks[[i]], collapse = ' ')}")
      )
    },
    character(1)
  )

  c(
    declarations,
    "",
    "\tlocal null_confirmed",
    str_glue("\tforvalues i = 1/{max_locals} {{"),
    "\t\tif \"`nullvars`i\'\'\" != \"\" {",
    "\t\t\tforeach stub of local nullvars`i\' {",
    "\t\t\t\tcap unab matched : `stub\'*",
    "\t\t\t\tif !_rc {",
    "\t\t\t\t\tforeach var of local matched {",
    "\t\t\t\t\t\tif regexm(\"`var\'\", \"^`stub\'(_[0-9]+)*$\") {",
    "\t\t\t\t\t\t\tqui count if !missing(`var\')",
    "\t\t\t\t\t\t\tif r(N) == 0 {",
    "\t\t\t\t\t\t\t\tlocal null_confirmed `null_confirmed\' `var\'",
    "\t\t\t\t\t\t\t}",
    "\t\t\t\t\t\t}",
    "\t\t\t\t\t}",
    "\t\t\t\t}",
    "\t\t\t}",
    "\t\t}",
    "\t}",
    "",
    "\tif \"`null_confirmed\'\" != \"\" {",
    "\t\tdrop `null_confirmed\'",
    "\t}",
    ""
  )
}

# Stata block converting exported string dates to numeric ----
build_datetime_block <- function(datetime_vars, date_vars, topyear) {
  loop <- function(vars, fn, mask, fmt) {
    if (length(vars) == 0) {
      return(character(0))
    }
    c(
      str_glue("\tlocal dtvarlist {paste(vars, collapse = ' ')}"),
      "\tforeach dtvar in `dtvarlist' {",
      # Only a string can be parsed. Without this, a second run would
      # replace an already converted variable with missing values.
      "\t\tcap confirm string variable `dtvar'",
      "\t\tif !_rc {",
      "\t\t\ttempvar tempdtvar",
      "\t\t\trename `dtvar' `tempdtvar'",
      "\t\t\tgen double `dtvar'=., after(`tempdtvar')",
      str_glue("\t\t\tcap replace `dtvar'={fn}(`tempdtvar',\"{mask}\",{topyear})"),
      str_glue("\t\t\tformat {fmt} `dtvar'"),
      "\t\t\tdrop `tempdtvar'",
      "\t\t}",
      "\t}",
      ""
    )
  }

  c(
    loop(datetime_vars, "clock", "MDYhms", "%tc"),
    loop(date_vars, "date", "MDY", "%td")
  )
}

# Split geopoint columns ----
# The raw geopoint is always kept. `separate_wider_delim()` with `names_sep`
# renames the column it retains to "<col>_<col>", so restore the original
# name afterwards.
split_gps_columns <- function(data, gps_fields) {
  if (length(gps_fields) == 0) {
    return(data)
  }

  nms <- names(data)
  suffix <- c("lat", "long", "alt", "acc")

  keep_idx <- sapply(gps_fields, function(pattern) {
    actual_col <- grep(pattern, nms, value = TRUE)
    if (length(actual_col) == 0) {
      return(FALSE)
    }
    check_fld <- paste0(actual_col[1], "_", suffix[1])
    !(check_fld %in% nms)
  })
  gps_fields <- gps_fields[keep_idx]

  if (length(gps_fields) == 0) {
    return(data)
  }

  out <- tidyr::separate_wider_delim(
    data = data,
    cols = matches(gps_fields),
    delim = " ",
    names = suffix,
    names_sep = "_",
    too_few = "align_start",
    # A malformed point must not abort the split for every other column.
    too_many = "drop",
    cols_remove = FALSE
  )

  kept <- paste0(nms, "_", nms)
  restore <- kept %in% names(out) & !(nms %in% names(out))
  if (any(restore)) {
    names(out)[match(kept[restore], names(out))] <- nms[restore]
  }

  out
}

# Center text -----
center_text <- function(text, fill = " ", width = 78) {
  checkmate::assert_string(fill)
  if (nchar(text) < width) {
    padding_total <- width - nchar(text)
    left_pad <- floor(padding_total / 2)
    right_pad <- ceiling(padding_total / 2)
    paste0(strrep(fill, left_pad), text, strrep(fill, right_pad))
  } else {
    text
  }
}

# Generate regex variable name ----
gen_regex_varname <- function(name, rpt_lvl, multi, mp = "_*[0-9]+") {
  if (rpt_lvl == 0) {
    if (multi) {
      return(paste0("^", name, mp, "$"))
    } else {
      return(paste0("^", name, "$"))
    }
  } else {
    rpt <- strrep("_[0-9]+", rpt_lvl)
    if (multi) {
      return(paste0("^", name, mp, rpt, "$"))
    } else {
      return(paste0("^", name, rpt, "$"))
    }
  }
}
