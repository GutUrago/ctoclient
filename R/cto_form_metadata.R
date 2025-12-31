

#' Download SurveyCTO Form Metadata
#'
#' @description
#' Retrieves metadata associated with a SurveyCTO form from the server.
#'
#'
#' @param req A `httr2_request` object initialized via \code{\link{cto_request}()}.
#' @param form_id String. The unique ID of the SurveyCTO form.
#'
#' @details
#' The metadata is retrieved via the SurveyCTO API and returned as a nested list
#' mirroring the server response. It typically includes details for the
#' currently deployed form definition as well as any previously deployed
#' versions.
#'
#'
#' @return
#' A named `list` containing form metadata as returned by the
#' SurveyCTO server.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Initialize a SurveyCTO request
#' req <- cto_request("my-org", "user@org.com")
#'
#' # Retrieve metadata for a form
#' meta <- cto_form_metadata(req, form_id = "household_survey")
#' }
cto_form_metadata <- function(req, form_id) {

  verbose <- isTRUE(getOption("scto.verbose", default = TRUE))

  assert_class(req, c("httr2_request", "scto_request"))
  assert_string(form_id, min.chars = 1)

  if (verbose) cli_progress_step("Preparing metadata download")

  unix_ms <- as.numeric(Sys.time()) * 1000
  url_path <- str_glue("forms/{form_id}/files")

  if (verbose) cli_progress_step("Downloading form metadata...")
  form_metadata <- req |>
    req_url_path(url_path) |>
    req_url_query(t = unix_ms) |>
    req_perform() |>
    resp_body_json(simplifyVector = TRUE)

  if (verbose) cli_progress_step("Download complete!")
  invisible(form_metadata)
}

