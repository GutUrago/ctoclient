

#' Download SurveyCTO Form Definitions
#'
#' @description
#' Downloads the XLSForm definition for a specified SurveyCTO form.
#'
#' @param req A `httr2_request` object initialized via \code{\link{cto_request}()}.
#' @param form_id String. The unique ID of the SurveyCTO form.
#' @param deployed_only Logical. If `TRUE` (default), only the currently deployed
#'   form version is retrieved. If `FALSE`, all available historical versions are
#'   downloaded and parsed.
#'
#' @details
#' The XLSForm file is downloaded from the SurveyCTO server and parsed using
#' \pkg{openxlsx2}. The returned object contains the three core XLSForm sheets
#' required to understand form structure and logic:
#' \code{survey}, \code{choices}, and \code{settings}.
#'
#'
#' @return a `list`. When `deployed_only = FALSE`, each form version is returned as a separate
#' list element, named using the corresponding form version identifier.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Initialize a SurveyCTO request
#' req <- cto_request("my-org", "user@org.com")
#'
#' # Download the currently deployed version of a form
#' form_id <- "household_survey"
#' form_def <- cto_form_definitions(req, form_id)
#'
#' # Download all historical versions of the form
#' all_defs <- cto_form_definitions(req, form_id, FALSE)
#' }
cto_form_definitions <- function(req, form_id, deployed_only = TRUE) {

  verbose <- isTRUE(getOption("scto.verbose", default = TRUE))

  assert_class(req, c("httr2_request", "scto_request"))
  assert_string(form_id)
  assert_flag(deployed_only)

  if (verbose) cli_progress_step("Preparing form download")
  file_list <- cto_form_metadata(req, form_id)

  if (deployed_only) {

    if (verbose) cli_progress_step("Downloading deployed form version...")
    download_url <- file_list[["deployedGroupFiles"]][["definitionFile"]][["downloadLink"]]
    temp_file <- tempfile(fileext = ".xlsx")

    req |>
      req_url(download_url) |>
      req_perform() |>
      resp_body_raw() |>
      writeBin(temp_file)

    sheets <- c("survey", "choices", "settings")
    form_out <- purrr::map(sheets,
                           ~openxlsx2::wb_to_df(
                             file = temp_file,
                             sheet = .x,
                             convert = FALSE,
                             skip_empty_rows = TRUE,
                             skip_empty_cols = TRUE))
    unlink(temp_file)
    names(form_out) <- sheets

  } else {

    all_versions <- dplyr::bind_rows(
      file_list[["deployedGroupFiles"]][["definitionFile"]],
      file_list[["previousDefinitionFiles"]]
      )

    form_versions <- all_versions[["formVersion"]]
    download_urls <- all_versions[["downloadLink"]]

    if (verbose) cli_progress_step("Downloading {.val {length(form_versions)}} form version{?s}...")

    form_out <- purrr::map2(form_versions, download_urls,
                .f = \(ver, url) {

                  temp_file <- tempfile(fileext = ".xlsx")

                  req |>
                    req_url(url) |>
                    req_perform() |>
                    resp_body_raw() |>
                    writeBin(temp_file)

                  sheets <- c("survey", "choices", "settings")
                  out <- purrr::map(sheets,
                                    ~openxlsx2::wb_to_df(
                                      file = temp_file,
                                      sheet = .x,
                                      convert = FALSE,
                                      skip_empty_rows = TRUE,
                                      skip_empty_cols = TRUE))
                  unlink(temp_file)
                  names(out) <- sheets
                  out
                })
    names(form_out) <- paste0("version_", form_versions)
  }

  if (verbose) cli_progress_step("Download complete!")
  invisible(form_out)
}
