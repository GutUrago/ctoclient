

cto_form_delete <- function(req, form_id) {
  verbose <- isTRUE(getOption("scto.verbose", default = TRUE))
  checkmate::assert_class(req, c("httr2_request", "scto_request"))
  checkmate::assert_string(form_id)
  if (verbose) cli_progress_step("Deleting {.val {form_id}}")
  url_path <- str_glue("forms/{form_id}/delete")
  res <- req_url_path(req, url_path) |>
    httr2::req_method("DELETE") |>
    req_perform()
  invisible(resp_body_json(res))
}
