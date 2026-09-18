
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
