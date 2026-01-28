
#' Delete a Form from the Server
#'
#' @description
#' Permanently removes a form definition and its associated data from the
#' SurveyCTO server.
#'
#' **Warning:** This action cannot be undone. All data collected using this
#' form will be lost unless backed up previously.
#'
#' @param form_id String. The unique identifier of the form to delete
#'   (e.g., `"household_survey_v1"`).
#'
#' @return (Invisibly) A list containing the server response confirmation.
#'
#' @family Form Management
#'
#' @examples
#' \dontrun{
#' # Delete a specific form by ID
#' cto_form_delete("household_baseline_2024")
#' }
cto_form_delete <- function(form_id) {
  verbose <- get_verbose()
  assert_form_id(form_id)
  session <- get_session()
  if (verbose) cli_progress_step("Deleting {.val {form_id}}")
  url_path <- str_glue("forms/{form_id}/delete")
  res <- req_url_path(session, url_path) |>
    httr2::req_method("DELETE") |>
    req_perform()
  invisible(resp_body_json(res))
}
