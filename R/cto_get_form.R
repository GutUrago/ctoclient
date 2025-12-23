

#' Download and Parse SurveyCTO Form Definitions
#'
#' @description
#' `cto_get_form()` retrieves the XLSForm definition of a specified form from
#' a SurveyCTO server. It allows for downloading the currently deployed version
#' or a specific previous version, and returns the definition as a list of
#' data frames (one for each standard XLSForm sheet) and optionally writes to local disc.
#'
#' @param req A \code{httr2} request object initialized via
#' \code{\link{cto_request}()}.
#' @param form_id String. The unique ID of the form you wish to retrieve.
#' @param form_version Optional numeric. The specific version of the
#' form to download. If \code{NULL} (the default), the function retrieves the
#' currently deployed version.
#' @param file_path String. The local path where the \code{.xlsx} file will
#' be saved. Defaults to a temporary file.
#' @param overwrite Logical. Should the file at \code{file_path} be overwritten
#' if it already exists? Defaults to \code{FALSE}.
#'
#' @details
#' The function first queries the SurveyCTO API to list all available files
#' associated with the \code{form_id}. If a \code{form_version} is specified
#' but not found, the function provides a helpful error message listing all
#' valid versions available on the server.
#'
#' Once downloaded, the \code{.xlsx} file is parsed using \code{openxlsx2}.
#' The returned list contains the three core XLSForm components required for
#' understanding form logic and data structure: \code{survey}, \code{choices},
#' and \code{settings}.
#'
#' @section Security Note:
#' Like all functions in this package, \code{cto_get_form()} utilizes the
#' provided \code{req} object which stores credentials securely. No sensitive
#' information is printed to the console during the version check or download
#' process.
#'
#' @return A named \code{list} containing three data frames and a vector of form versions:
#' \itemize{
#'   \item \code{survey}: The main form structure (types, names, labels, etc.).
#'   \item \code{choices}: The multiple-choice options and categories.
#'   \item \code{settings}: Form-level settings including the form title and ID.
#'   \item \code{form_versions}: A vector of available form versions on the server.
#' }
#' The list is returned invisibly.
#'
#' @export
#' @author Gutama Girja Urago
#'
#' @examples
#' \dontrun{
#' # Prepare the request using environment variables
#' req <- cto_request(auth_file = Sys.getenv("SCTO_AUTH_FILE"))
#'
#' # Download the latest version of a form
#' form_def <- cto_get_form(req, form_id = "household_survey")
#'
#' # View the choices sheet
#' print(form_def$choices)
#'
#' # Download a specific historical version
#' old_def <- cto_get_form(req, "household_survey", form_version = "2201051530")
#' }
cto_get_form <- function(req,
                         form_id,
                         form_version = NULL,
                         file_path = tempfile(fileext = ".xlsx"),
                         overwrite = FALSE) {

  verbose <- isTRUE(getOption("scto.verbose", default = TRUE))
  if (verbose) cli::cli_progress_step("Preparing to download...", spinner = TRUE)

  checkmate::assert_class(req, c("httr2_request", "scto_request"))
  checkmate::assert_character(form_id, min.len = 1, max.len = 1)
  if (!is.null(form_version)) checkmate::assert_vector(form_version, len = 1L)
  checkmate::assert_path_for_output(file_path, overwrite = overwrite, extension = "xlsx")

  unix_ms <- as.numeric(Sys.time()) * 1000
  url_path <- stringr::str_glue("forms/{form_id}/files")

  if (verbose) cli::cli_progress_step("Checking form version...", spinner = TRUE)

  file_list <- req |>
    cto_url_path_append(url_path) |>
    cto_url_query(t = unix_ms) |>
    cto_perform() |>
    cto_body_json(simplifyVector = TRUE)

  deployed_version <- file_list[["deployedGroupFiles"]][["definitionFile"]][["formVersion"]]
  form_versions <- c(deployed_version,
                     file_list[["previousDefinitionFiles"]][["formVersion"]])
  if (is.null(form_version)) {
    form_url <- file_list[["deployedGroupFiles"]][["definitionFile"]][["downloadLink"]]
  } else {
    all_versions <- file_list[["previousDefinitionFiles"]]
    if (!(form_version %in% form_versions)) {
      cli::cli_abort(
        c(
          "x" = "The specified form version {.val {form_version}} was not found on the server.",
          "i" = "Available versions for this form: {.field {paste(form_versions, collapse = ', ')}}",
          "!" = "Please check for typos or use the latest version by setting {.code form_version = NULL}."
        ),
        call = NULL
      )
    }
    form_url <- all_versions[["downloadLink"]][form_versions == form_version]
  }

  if (verbose) cli::cli_progress_step("Starting form download...", spinner = TRUE)
  survey_form <- req |>
    httr2::req_url(form_url) |>
    cto_perform() |>
    httr2::resp_body_raw() |>
    writeBin(file_path)

  sheets <- c("survey", "choices", "settings")
  out <- list()
  for (sheet in sheets) {
    out[[sheet]] <- openxlsx2::read_xlsx(
      file_path,
      sheet = sheet,
      skip_empty_rows = TRUE,
      skip_empty_cols = TRUE)
  }
  out[["form_versions"]] <- form_versions
  if (verbose) cli::cli_progress_done("Form download complete!")
  return(invisible(out))
}
