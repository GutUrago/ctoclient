

#' Delete or Purge a Dataset
#'
#' @description
#' Functions to permanently remove data from the server.
#'
#' * `cto_delete_dataset()`: **Permanently deletes** the dataset definition and
#'   all associated records. The dataset ID will no longer exist.
#' * `cto_purge_dataset()`: Removes **all records** from the dataset but
#'   keeps the dataset definition (schema/ID) intact.
#'
#' @param id String. The unique identifier of the dataset.
#'
#' @return A list confirming the operation status.
#'
#' @name cto_dataset_delete
#' @family Dataset Management Functions
#' @export
#'
#' @examples
#' \dontrun{
#' # 1. Delete dataset
#' cto_dataset_delete(id = "hh_data")
#'
#' # 2. Purge dataset
#' cto_dataset_purge(id = "hh_data")
#' }
cto_dataset_delete <- function(id) {
  checkmate::assert_string(id)
  verbose <- get_verbose()
  session <- get_session()

  if (verbose) cli_progress_step(
    "Deleting dataset with {col_blue(id)} ID",
    "Dataset with ID {col_blue(id)} deleted"
  )

  path <- str_glue("api/v2/datasets/{id}")
  session <- httr2::req_method(session, "DELETE")
  res <- fetch_api_response(session, path)
  class(res) <- "simple.list"
  res
}

#' @export
#' @rdname cto_dataset_delete
cto_dataset_purge <- function(id) {
  checkmate::assert_string(id)
  verbose <- get_verbose()
  session <- get_session()

  if (verbose) cli_progress_step(
    "Purging dataset with {col_blue(id)} ID",
    "Dataset with ID {col_blue(id)} purged"
  )

  path <- str_glue("/api/v2/datasets/{id}/purge")
  session <- httr2::req_method(session, "POST")
  res <- fetch_api_response(session, path)
  class(res) <- "simple.list"
  res
}
