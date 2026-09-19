
# Unit tests for the internal helpers in R/zzz.R. These are pure functions,
# so they need neither a connection nor a fixture.

# ---- gen_regex_varname() ----

test_that(
  "gen_regex_varname() anchors plain variable names",
  {
    expect_identical(gen_regex_varname("age", 0, FALSE), "^age$")
    expect_identical(gen_regex_varname("age", 1, FALSE), "^age_[0-9]+$")
    expect_identical(gen_regex_varname("age", 2, FALSE), "^age_[0-9]+_[0-9]+$")
  }
)

test_that(
  "gen_regex_varname() appends the select_multiple suffix",
  {
    expect_identical(gen_regex_varname("crops", 0, TRUE), "^crops_*[0-9]+$")
    expect_identical(gen_regex_varname("crops", 1, TRUE), "^crops_*[0-9]+_[0-9]+$")
    expect_identical(gen_regex_varname("crops", 0, TRUE, "_values"), "^crops_values$")
  }
)

test_that(
  "gen_regex_varname() patterns select the columns they describe",
  {
    nms <- c("age", "age_1", "age_1_2", "crops_1", "crops_2", "cropsx")
    expect_identical(
      grep(gen_regex_varname("age", 0, FALSE), nms, value = TRUE),
      "age"
    )
    expect_identical(
      grep(gen_regex_varname("age", 1, FALSE), nms, value = TRUE),
      "age_1"
    )
    expect_identical(
      grep(gen_regex_varname("age", 2, FALSE), nms, value = TRUE),
      "age_1_2"
    )
    expect_identical(
      grep(gen_regex_varname("crops", 0, TRUE), nms, value = TRUE),
      c("crops_1", "crops_2")
    )
  }
)


# ---- center_text() ----

test_that(
  "center_text() pads text to the requested width",
  {
    expect_identical(center_text("ab", "-", 6), "--ab--")
    expect_identical(nchar(center_text("abc", " ", 78)), 78L)
  }
)

test_that(
  "center_text() puts the extra character on the right",
  {
    expect_identical(center_text("ab", "-", 7), "--ab---")
  }
)

test_that(
  "center_text() returns text wider than the width unchanged",
  {
    expect_identical(center_text("abcdef", "-", 6), "abcdef")
    expect_identical(center_text("abcdefg", "-", 6), "abcdefg")
  }
)


# ---- drop_nulls_recursive() ----

test_that(
  "drop_nulls_recursive() drops NULL elements at every level",
  {
    x <- list(a = 1, b = NULL, c = list(d = NULL, e = 2))
    expect_identical(drop_nulls_recursive(x), list(a = 1, c = list(e = 2)))
  }
)

test_that(
  "drop_nulls_recursive() drops lists left empty",
  {
    expect_identical(drop_nulls_recursive(list(a = 1, b = list())), list(a = 1))
    expect_length(drop_nulls_recursive(list(a = list(b = NULL))), 0)
  }
)

test_that(
  "drop_nulls_recursive() returns non-lists unchanged",
  {
    expect_identical(drop_nulls_recursive(1:3), 1:3)
    expect_identical(drop_nulls_recursive("a"), "a")
  }
)


# ---- assert_url_safe() ----

test_that(
  "assert_url_safe() accepts names a server may legitimately use",
  {
    expect_true(assert_url_safe("sctopackagetest", "server"))
    expect_true(assert_url_safe("my-org", "server"))
    expect_true(assert_url_safe("my_org", "server"))
    expect_true(assert_url_safe("MyOrg", "server"))
    expect_true(assert_url_safe(c("hh_listing", "sample.cases"), "id"))
  }
)

test_that(
  "assert_url_safe() rejects characters that change the URL structure",
  {
    expect_error(assert_url_safe("evil.com/#", "server"), "must not contain", fixed = TRUE)
    expect_error(assert_url_safe("a?b", "server"), "must not contain", fixed = TRUE)
    expect_error(assert_url_safe("a#b", "server"), "must not contain", fixed = TRUE)
    expect_error(assert_url_safe("a/b", "id"), "must not contain", fixed = TRUE)
    expect_error(assert_url_safe("a b", "id"), "must not contain", fixed = TRUE)
    expect_error(assert_url_safe("host:8080", "server"), "must not contain", fixed = TRUE)
    expect_error(assert_url_safe("user@host", "server"), "must not contain", fixed = TRUE)
  }
)

test_that(
  "assert_url_safe() rejects empty and missing values",
  {
    expect_error(assert_url_safe("", "id"))
    expect_error(assert_url_safe(NA_character_, "id"))
  }
)

test_that(
  "assert_url_safe() names the offending element",
  {
    expect_error(assert_url_safe(c("good", "al/so"), "id"), "al/so", fixed = TRUE)
  }
)

test_that(
  "cto_connect() rejects an unsafe server before contacting the network",
  {
    expect_error(
      cto_connect("evil.com/#", "user", "pass"),
      "must not contain",
      fixed = TRUE
    )
  }
)


# ---- split_gps_columns() ----

test_that(
  "split_gps_columns() keeps the raw geopoint under its own name",
  {
    d <- data.frame(
      id = 1:2,
      gps = c("9.0 38.7 2355 4.9", "9.1 38.8 2360 5.0"),
      stringsAsFactors = FALSE
    )
    out <- split_gps_columns(d, "^gps$")

    expect_true("gps" %in% names(out))
    expect_identical(out$gps, d$gps)
    expect_false(any(grepl("gps_gps", names(out))))
    expect_true(all(c("gps_lat", "gps_long", "gps_alt", "gps_acc") %in% names(out)))
    expect_identical(out$gps_lat, c("9.0", "9.1"))
  }
)

test_that(
  "split_gps_columns() handles several geopoints at once",
  {
    d <- data.frame(
      gps = c("9.0 38.7 2355 4.9"),
      plot_gps = c("8.1 39.2 1800 6.0"),
      stringsAsFactors = FALSE
    )
    out <- split_gps_columns(d, c("^gps$", "^plot_gps$"))

    expect_identical(out$gps, d$gps)
    expect_identical(out$plot_gps, d$plot_gps)
    expect_identical(out$plot_gps_long, "39.2")
  }
)

test_that(
  "split_gps_columns() survives a malformed point",
  {
    d <- data.frame(
      gps = c("9.0 38.7 2355 4.9", "9.0 38.7 2355 4.9 99", "9.0 38.7"),
      stringsAsFactors = FALSE
    )
    out <- expect_no_error(split_gps_columns(d, "^gps$"))

    expect_identical(out$gps, d$gps)
    expect_identical(out$gps_lat, c("9.0", "9.0", "9.0"))
    expect_true(is.na(out$gps_acc[3]))
  }
)

test_that(
  "split_gps_columns() returns the data untouched when there is nothing to split",
  {
    d <- data.frame(id = 1:2, name = c("a", "b"), stringsAsFactors = FALSE)
    expect_identical(split_gps_columns(d, character(0)), d)
    expect_identical(split_gps_columns(d, "^gps$"), d)
  }
)


# ---- fetch_paginated_response() ----

test_that(
  "fetch_paginated_response() follows the cursor to the end",
  {
    calls <- 0L
    local_mocked_bindings(
      fetch_api_response = function(req, url_path = NULL, file_path = NULL) {
        calls <<- calls + 1L
        if (calls == 1L) {
          list(data = data.frame(i = 1L), nextCursor = "c1")
        } else {
          list(data = data.frame(i = 2L), nextCursor = NULL)
        }
      }
    )
    out <- fetch_paginated_response(httr2::request("https://example.com"), "x")

    expect_equal(nrow(out), 2L)
    expect_equal(calls, 2L)
  }
)

test_that(
  "fetch_paginated_response() stops when the cursor stops advancing",
  {
    calls <- 0L
    local_mocked_bindings(
      fetch_api_response = function(req, url_path = NULL, file_path = NULL) {
        calls <<- calls + 1L
        list(data = data.frame(i = calls), nextCursor = "stuck")
      }
    )
    expect_warning(
      fetch_paginated_response(httr2::request("https://example.com"), "x"),
      "same cursor"
    )
    expect_lt(calls, 5L)
  }
)

test_that(
  "fetch_paginated_response() stops at max_pages",
  {
    calls <- 0L
    local_mocked_bindings(
      fetch_api_response = function(req, url_path = NULL, file_path = NULL) {
        calls <<- calls + 1L
        list(data = data.frame(i = calls), nextCursor = paste0("c", calls))
      }
    )
    expect_warning(
      fetch_paginated_response(httr2::request("https://example.com"), "x", max_pages = 3),
      "Stopped after"
    )
    expect_equal(calls, 3L)
  }
)


# ---- stata_escape_label() ----

test_that(
  "stata_escape_label() neutralises Stata macro syntax",
  {
    expect_identical(stata_escape_label("Cost ($USD)"), "Cost (\\$USD)")
    expect_identical(stata_escape_label("${calculated}"), "\\${calculated}")
    expect_identical(stata_escape_label("a `b` c"), "a 'b' c")
    expect_identical(stata_escape_label('He said "hi"'), "He said 'hi'")
    expect_identical(stata_escape_label("<b>Bold</b> text"), "Bold text")
    expect_identical(stata_escape_label("Plain label"), "Plain label")
  }
)


# ---- build_datetime_block() ----

test_that(
  "build_datetime_block() uses clock/%tc for datetimes and date/%td for dates",
  {
    out <- build_datetime_block("SubmissionDate", "visit_date", "2026")

    expect_true(any(grepl("local dtvarlist SubmissionDate", out, fixed = TRUE)))
    expect_true(any(grepl("clock(`tempdtvar',\"MDYhms\",2026)", out, fixed = TRUE)))
    expect_true(any(grepl("format %tc `dtvar'", out, fixed = TRUE)))

    expect_true(any(grepl("local dtvarlist visit_date", out, fixed = TRUE)))
    expect_true(any(grepl("date(`tempdtvar',\"MDY\",2026)", out, fixed = TRUE)))
    expect_true(any(grepl("format %td `dtvar'", out, fixed = TRUE)))
  }
)

test_that(
  "build_datetime_block() skips variables the dataset does not have",
  {
    out <- build_datetime_block("SubmissionDate", character(0), "2026")

    expect_true(any(grepl("cap confirm string variable `dtvar'", out, fixed = TRUE)))
    expect_true(any(grepl("if !_rc {", out, fixed = TRUE)))
  }
)

test_that(
  "build_datetime_block() emits only the lists it is given",
  {
    expect_length(build_datetime_block(character(0), character(0), "2026"), 0)
    expect_false(any(grepl("clock(", build_datetime_block(character(0), "today", "2026"), fixed = TRUE)))
    expect_false(any(grepl("date(", build_datetime_block("endtime", character(0), "2026"), fixed = TRUE)))
  }
)

test_that(
  "build_datetime_block() lists several variables in one local",
  {
    out <- build_datetime_block(c("SubmissionDate", "starttime", "endtime"), character(0), "2026")
    expect_true(any(grepl("local dtvarlist SubmissionDate starttime endtime", out, fixed = TRUE)))
  }
)


# ---- form_null_vars() ----

test_that(
  "form_null_vars() finds structural fields at the level they are exported",
  {
    type <- c(
      "note", "begin_group", "integer", "end_group",
      "begin repeat", "note", "integer", "end repeat", "text"
    )
    name <- c("n1", "g1", "q1", "", "rpt", "n2", "q2", "", "q3")
    out <- form_null_vars(name, type)

    expect_setequal(out$stub, c("n1", "g1", "rpt_count", "n2"))
    expect_equal(out$level[out$stub == "n1"], 0)
    expect_equal(out$level[out$stub == "g1"], 0)
    # the repeat counter sits one level outside the repeat it counts
    expect_equal(out$level[out$stub == "rpt_count"], 0)
    # a note inside the repeat is exported once per instance
    expect_equal(out$level[out$stub == "n2"], 1)
  }
)

test_that(
  "form_null_vars() matches both the spaced and underscored spellings",
  {
    spaced <- form_null_vars(c("g", "r"), c("begin group", "begin repeat"))
    under <- form_null_vars(c("g", "r"), c("begin_group", "begin_repeat"))
    expect_setequal(spaced$stub, under$stub)
    expect_setequal(under$stub, c("g", "r_count"))
  }
)

test_that(
  "form_null_vars() ignores unnamed rows and real questions",
  {
    type <- c("end_group", "end repeat", "integer", "select_one yn", "geopoint")
    name <- c("", NA, "q1", "q2", "q3")
    expect_equal(nrow(form_null_vars(name, type)), 0)
  }
)


# ---- build_null_block() ----

test_that(
  "build_null_block() chunks long lists into one local per level",
  {
    nulls <- data.frame(
      stub = c(paste0("n", 1:8), "deep"),
      level = c(rep(0, 8), 1),
      stringsAsFactors = FALSE
    )
    txt <- paste(build_null_block(nulls, per_line = 6), collapse = "\n")

    expect_match(txt, "local nullvars0 n1 n2 n3 n4 n5 n6", fixed = TRUE)
    expect_match(txt, "local nullvars0 `nullvars0' n7 n8", fixed = TRUE)
    expect_match(txt, "local nullvars1 deep", fixed = TRUE)
  }
)

test_that(
  "build_null_block() walks the levels with a single loop",
  {
    nulls <- data.frame(
      stub = c("a", "b"),
      level = c(0, 1),
      stringsAsFactors = FALSE
    )
    out <- build_null_block(nulls)
    txt <- paste(out, collapse = "\n")

    # one loop over the level index, not one loop per level
    expect_equal(sum(grepl("foreach stub of local", out, fixed = TRUE)), 1L)
    expect_match(txt, "forvalues lvl = 0/100 {", fixed = TRUE)
    # the level names the macro to read
    expect_match(txt, "local stublist `nullvars`lvl\'\'", fixed = TRUE)
    # empty levels are skipped
    expect_match(txt, "if \"`stublist'\" != \"\" {", fixed = TRUE)
    # and the pattern is rebuilt from the level
    expect_match(txt, "local suffix `suffix'_[0-9]+", fixed = TRUE)
    expect_match(txt, "if regexm(\"`var'\", \"^`stub'`suffix'$\")", fixed = TRUE)
  }
)

test_that(
  "build_null_block() respects a different level cap",
  {
    nulls <- data.frame(stub = "a", level = 0, stringsAsFactors = FALSE)
    txt <- paste(build_null_block(nulls, max_level = 20), collapse = "\n")
    expect_match(txt, "forvalues lvl = 0/20 {", fixed = TRUE)
  }
)

test_that(
  "build_null_block() confirms a variable is empty before dropping it",
  {
    nulls <- data.frame(stub = "n1", level = 0, stringsAsFactors = FALSE)
    txt <- paste(build_null_block(nulls), collapse = "\n")

    expect_match(txt, "cap unab matched : `stub'*", fixed = TRUE)
    expect_match(txt, "qui count if !missing(`var')", fixed = TRUE)
    expect_match(txt, "if r(N) == 0 {", fixed = TRUE)
    expect_match(txt, "local null_confirmed `null_confirmed' `var'", fixed = TRUE)
    expect_match(txt, "drop `null_confirmed'", fixed = TRUE)
  }
)

test_that(
  "build_null_block() emits nothing when there is nothing to drop",
  {
    empty <- data.frame(stub = character(0), level = numeric(0))
    expect_length(build_null_block(empty), 0)
  }
)
