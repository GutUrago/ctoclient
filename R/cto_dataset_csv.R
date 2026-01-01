
#' Download SurveyCTO datasets as CSV files
#'
#' Downloads one or more SurveyCTO datasets in CSV format and saves them to
#' a specified directory. Each dataset is written as a separate `.csv` file
#' named after its dataset ID.
#'
#' @param req A `httr2_request` object initialized via \code{\link{cto_request}()}.
#' @param ids A character vector of dataset IDs to download. Available IDs can
#'   be listed using \code{\link{cto_metadata}}.
#' @param dir Directory where CSV files should be saved. Defaults to the
#'   current working directory.
#'
#' @details
#' This function validates requested dataset IDs against those available to
#' the authenticated user. If any requested ID is unavailable or inaccessible,
#' the function aborts with an informative error.
#'
#' @return
#' Invisibly returns \code{NULL}. Called for its side effect of downloading
#' CSV files to disk.
#'
#' @seealso
#' \code{\link{cto_metadata}} to list available datasets.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' req <- cto_request(Sys.getenv("SCTO_SERVER"), Sys.getenv("SCTO_USER"))
#'
#' # List available datasets
#' dfs <- cto_metadata(req, "datasets")
#'
#' # Download selected datasets
#' cto_dataset_csv(req, ids = c("household_survey", "roster"))
#' }
#'
cto_dataset_csv <- function(req, ids, dir = getwd()) {
  verbose <- isTRUE(getOption("scto.verbose", default = TRUE))
  assert_class(req, c("httr2_request", "scto_request"))
  checkmate::assert_directory_exists(dir)
  checkmate::assert_character(ids)

  if (verbose) cli_progress_step("Checking form IDs")

  datasets <- cto_datasets(req)
  all_ids <- datasets$id
  if (!all(ids %in% all_ids)) {
    cli_abort(c(
      x = "You have either requested unavailable dataset or don't have access to the dataset.",
      i = "Please use {.fn cto_datasets} to see available ids of all datasets"
    ))
  }
  paths <- file.path(dir, paste0(ids, ".csv"))

  if (verbose) {
    cli_progress_step("Downloading datasets")
    pb <- list(
      type = "download",
      format = "Downloading {cli::pb_current}/{cli::pb_total} ({cli::ansi_trimws(cli::pb_percent)}) | {cli::ansi_trimws(cli::pb_rate_bytes)} ETA: {cli::pb_eta}"
    )
  } else pb <- FALSE

  purrr::walk2(
    ids, paths,
    function(id, path) {
      url_path <- str_glue("/api/v2/datasets/data/csv/{id}")
      req |>
        req_url_path(url_path) |>
        req_perform(path)
    },
    .progress = pb
  )
}
