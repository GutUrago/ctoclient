

#' Create or Upload to Server Datasets
#'
#' @description
#' These functions manage the lifecycle of SurveyCTO server datasets: creating the
#' container definition and populating it with data.
#'
#' * `cto_dataset_create()`: Defines a new empty dataset container on the server.
#' * `cto_dataset_upload()`: Uploads a CSV file to an existing dataset.
#'
#' @param id String. The unique identifier for the dataset (e.g., "household_data").
#' @param file String. Path to the local CSV file to upload.
#' @param title String. The display title of the dataset. Defaults to `id`.
#' @param parent_group_id Integer. The ID of the group the dataset belongs to. Defaults to `1`.
#' @param discriminator String. The type of dataset to create. Options are:
#'   * `"data"`: Standard server dataset.
#'   * `"cases"`: Case management dataset.
#'   * `"enumerators"`: Enumerator dataset.
#' @param unique_record_field String (Optional). The name of the field that
#'   uniquely identifies records. Required if `upload_mode` is "merge".
#' @param upload_mode String. How the data should be handled:
#'   * `"append"`: Add new rows to the existing data.
#'   * `"merge"`: Update existing rows based on the `joining_field` and add new ones.
#'   * `"clear"`: Wipe existing data before uploading.
#' @param joining_field String (Optional). The column name used to match records
#'   during a "merge". Often the same as `unique_record_field`.
#'
#' @return A list containing the API response (metadata for creation, or job summary for upload).
#'
#' @family Dataset Management Functions
#' @export
#'
#' @examples
#' \dontrun{
#' # --- Approach 1: Granular Control ---
#' # 1. Create the container
#' cto_dataset_create(
#' id = "hh_data",
#' title = "Household Data",
#' unique_record_field = "hh_id"
#' )
#'
#' # 2. Upload data to it
#' cto_dataset_upload(
#' file = "data.csv",
#' id = "hh_data",
#' upload_mode = "merge",
#' joining_field = "hh_id"
#' )
#' }
cto_dataset_create <- function(id, title = id, parent_group_id = 1,
                               discriminator = c("data", "cases", "enumerators"),
                               unique_record_field = NULL) {
  verbose <- get_verbose()
  session <- get_session()
  checkmate::assert_string(unique_record_field, null.ok = TRUE)
  checkmate::assert_string(id)
  checkmate::assert_string(title)

  query <- list(
    id = id,
    title = title,
    locationContext = list(parentGroupId = parent_group_id),
    discriminator = toupper(match.arg(discriminator)),
    uniqueRecordField = unique_record_field
  )
  query <- drop_nulls_recursive(query)

  if (verbose) cli_progress_step(
    "Creating {col_blue(id)} dataset",
    "Created {col_blue(id)} dataset"
  )

  session <- httr2::req_body_json(session, query)
  session <- httr2::req_method(session, "POST")

  res <- fetch_api_response(session, "api/v2/datasets")
  class(res) <- "simple.list"
  res
}



#' @export
#' @rdname cto_dataset_create
cto_dataset_upload <- function(file, id, upload_mode = c("append", "merge", "clear"),
                               joining_field = NULL) {
  verbose <- get_verbose()
  session <- get_session()
  checkmate::assert_file_exists(file, 'r', "csv")
  checkmate::assert_string(joining_field, null.ok = TRUE)

  metadata <- list(
    joiningField = joining_field,
    uploadMode = toupper(match.arg(upload_mode))
  )

  metadata <- Filter(Negate(is.null), metadata)
  metadata_json <- jsonlite::toJSON(metadata)

  path <- str_glue("api/v2/datasets/{id}/records/upload")
  session <- httr2::req_body_multipart(
    session,
    metadata = curl::form_data(metadata_json, type = "application/json"),
    file = curl::form_file(file, type = "text/csv", name = "file")
  )

  session <- httr2::req_method(session, "POST")
  res <- fetch_api_response(session, path)
  class(res) <- "simple.list"
  res
}
