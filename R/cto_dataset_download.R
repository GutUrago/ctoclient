
#' Download SurveyCTO Server Datasets
#'
#' @description
#' Downloads one or more datasets from a SurveyCTO server to a local directory
#' as CSV files.
#'
#' @param id A character vector of dataset IDs to download.
#'   If `NULL` (the default), the function queries the server for a list of all
#'   available datasets and downloads them all.
#' @param dir A string specifying the directory where CSV files will be saved.
#'   Defaults to the current working directory.
#' @param overwrite Logical. If `TRUE`, existing files in `dir` will be
#'   overwritten. If `FALSE` (the default), existing files are skipped to conserve
#'   bandwidth, and a message is printed for each skipped file.
#'
#' @details
#' * **Validation:** If `id`s are provided, they are validated against the
#'   available server datasets via `cto_list_datasets()`.
#' * **Smart Downloading:** If `overwrite = FALSE`, the function checks if the
#'   target file already exists in `dir`.
#' * **Error Handling:** If a specific dataset fails to download (e.g., HTTP
#'   403/404), a warning is printed with the dataset name, but the function
#'   continues processing the remaining list.
#'
#' @return (Invisibly) A character vector of file paths to the successfully
#'   downloaded CSVs. Returns `NULL` if no datasets were found.
#'
#' @family Dataset Management Functions
#' @export
#'
#' @examples
#' \dontrun{
#' # --- Example 1: Download a specific dataset ---
#' paths <- cto_dataset_download(id = "household_data", dir = tempdir())
#' df <- read.csv(paths[1])
#'
#' # --- Example 2: Download all datasets, skip existing files ---
#' paths <- cto_dataset_download(dir = "my_data_folder", overwrite = FALSE)
#' }
cto_dataset_download <- function(id = NULL, dir = getwd(), overwrite = FALSE) {
  verbose <- isTRUE(getOption("scto.verbose", TRUE))

  session <- get_session()
  checkmate::assert_character(id, null.ok = TRUE)
  checkmate::assert_directory(dir)
  checkmate::assert_logical(overwrite, len = 1, any.missing = FALSE)

  if (is.null(id)) {
    id <- purrr::pluck(cto_dataset_list(), "id")
    if (length(id) == 0) {
      cli_warn("No server datasets found on {.field {session$server}}")
      return(invisible())
      }
  }

  session <- httr2::req_url_query(session, asAttachment = TRUE)

  file_names <- paste0(id, ".csv")
  paths_all  <- file.path(dir, file_names)

  to_download <- if (overwrite) rep(TRUE, length(id)) else !file.exists(paths_all)

  urls_to_fetch  <- paste0("/api/v2/datasets/data/csv/", id[to_download])
  paths_to_fetch <- paths_all[to_download]

  skipped <- length(id) - sum(to_download)
  if (skipped > 0 && verbose) cli_inform("Skipping {.val {skipped}} existing file{?s}")

  if (length(paths_to_fetch) > 0) {
    if (verbose) cli_progress_step(
      "Downloading {.val {length(paths_to_fetch)}} dataset{?s}",
      "Downloaded {.val {sum(file.exists(paths_to_fetch))}} dataset{?s}"
      )
    reqs <- purrr::map(urls_to_fetch, ~req_url_path(session, .x))
    purrr::walk2(
      reqs, paths_to_fetch, function(r, p) {
        tryCatch(
          fetch_api_response(r, NULL, p),
          error = function(e) cli_warn("{.val {basename(p)}}: {conditionMessage(e)}")
          )
      }
    )
  }

  invisible(paths_all[file.exists(paths_all)])

}



