
# End-to-end test of the Stata do-file generator. "fixtures/testform.xlsx" is a
# small XLSForm covering the cases the generator has to get right, so the only
# thing mocked out is the download.

dofile <- function(path = NULL) {
  local_mocked_bindings(
    cto_form_definition = function(...) test_path("fixtures", "testform.xlsx"),
    .package = "ctoclient"
  )
  old <- options(ctoclient.verbose = FALSE)
  on.exit(options(old), add = TRUE)
  cto_form_dofile("testform", path = path)
}

test_that(
  "the date and time lists come from the form definition",
  {
    out <- dofile()

    # starttime, endtime and interview_dt are the start/end/datetime questions
    expect_true(any(grepl(
      "local dtvarlist CompletionDate SubmissionDate starttime endtime interview_dt",
      out,
      fixed = TRUE
    )))
    # today and visit_date are the today/date questions
    expect_true(any(grepl("local dtvarlist today visit_date", out, fixed = TRUE)))
    # a question of any other type must not reach either list
    expect_false(any(grepl("dtvarlist.*hh_size", out)))
    expect_false(any(grepl("dtvarlist.*resp_name", out)))
  }
)

test_that(
  "date and datetime fields get the right function and format",
  {
    out <- paste(dofile(), collapse = "\n")

    expect_match(out, "clock(`tempdtvar',\"MDYhms\",", fixed = TRUE)
    expect_match(out, "format %tc `dtvar'", fixed = TRUE)
    expect_match(out, "date(`tempdtvar',\"MDY\",", fixed = TRUE)
    expect_match(out, "format %td `dtvar'", fixed = TRUE)
    expect_match(out, "cap confirm variable `dtvar'", fixed = TRUE)
  }
)

test_that(
  "integer and decimal questions are destrung before their labels",
  {
    out <- paste(dofile(), collapse = "\n")

    expect_match(
      out,
      "cap destring hh_size, replace\ncap label variable hh_size",
      fixed = TRUE
    )
    expect_match(
      out,
      "cap destring land_area, replace\ncap label variable land_area",
      fixed = TRUE
    )
    # an integer inside a repeat group is destrung too
    expect_match(
      out,
      "cap destring `var', replace\n\t\t\tcap label variable `var' \"Plot size\"",
      fixed = TRUE
    )
    # a text question is left alone
    expect_no_match(out, "cap destring resp_name", fixed = TRUE)
  }
)

test_that(
  "value labels are preceded by a destring",
  {
    out <- paste(dofile(), collapse = "\n")

    expect_match(
      out,
      "cap destring owns_land, replace\ncap label values owns_land yn",
      fixed = TRUE
    )
    expect_match(
      out,
      "cap destring `var', replace\n\t\t\tcap label values `var' slt_multi_binary",
      fixed = TRUE
    )
  }
)

test_that(
  "the default language wins over the first label column",
  {
    out <- paste(dofile(), collapse = "\n")

    # settings name English (en); the Amharic column comes first in the sheet
    expect_match(out, "cap label variable today \"Today\"", fixed = TRUE)
    expect_no_match(out, "ዛሬ", fixed = TRUE)
  }
)

test_that(
  "labels are escaped for Stata",
  {
    out <- paste(dofile(), collapse = "\n")

    expect_match(out, "Cost (\\$USD)", fixed = TRUE)
    expect_no_match(out, "Cost ($USD)", fixed = TRUE)
    expect_match(out, "Respondent name", fixed = TRUE)
    expect_no_match(out, "<b>", fixed = TRUE)
  }
)

test_that(
  "notes use Stata's note syntax",
  {
    out <- paste(dofile(), collapse = "\n")

    expect_match(out, "cap note hh_size: Household size", fixed = TRUE)
    expect_no_match(out, "cap note variable", fixed = TRUE)
    # the text after the colon is literal, so quotes would be stored as
    # part of the note
    expect_no_match(out, "cap note hh_size: \"", fixed = TRUE)
    expect_no_match(out, "cap note `var': \"", fixed = TRUE)
  }
)

test_that(
  "label define is capped and skips values Stata cannot use",
  {
    out <- paste(dofile(), collapse = "\n")

    expect_match(out, "cap label define yn 1 \"Yes\" 0 \"No\", modify", fixed = TRUE)
    # 1.5 is not a legal Stata value label
    expect_no_match(out, "1.5", fixed = TRUE)
  }
)

test_that(
  "writing to a path produces a readable UTF-8 file",
  {
    p <- file.path(tempdir(), "testform_labels.do")
    on.exit(unlink(p), add = TRUE)

    dofile(path = p)

    expect_true(file.exists(p))
    txt <- readLines(p, encoding = "UTF-8", warn = FALSE)
    expect_true(any(grepl("Land area in ha", txt, fixed = TRUE)))
    expect_true(all(validUTF8(txt)))
  }
)
