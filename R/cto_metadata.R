
#' Retrieve Metadata from a SurveyCTO Server
#'
#' This function retrieves structural metadata regarding forms, groups, and
#' datasets available on the server.
#'
#' @param req A `httr2_request` object initialized via \code{\link{cto_request}()}.
#' @param which A character string specifying which subset of metadata to return.
#'   One of:
#'   \itemize{
#'     \item \code{"all"} (default): Returns a list containing groups, datasets, and forms.
#'     \item \code{"groups"}: Returns a data frame of form groups.
#'     \item \code{"datasets"}: Returns a data frame of server datasets.
#'     \item \code{"forms"}: Returns a data frame of deployed forms.
#'   }
#'
#' @return
#'
#'`cto_form_ids` returns a vector of form IDs, and `cto_metadata` returns an
#'object containing the requested metadata.
#'   \itemize{
#'     \item If \code{which = "all"}, returns a named list.
#'     \item Otherwise, returns the specific \code{data.frame} requested.
#'   }
#'
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Authenticate first
#' req <- cto_request("myserver", "myuser")
#'
#' # Available form IDs
#' ids <- cto_form_ids(req)
#'
#' # Get all metadata
#' meta <- cto_metadata(req)
#' str(meta)
#'
#' # Get just the forms data frame
#' forms_df <- cto_metadata(req, which = "forms")
#' head(forms_df)
#' }
cto_metadata <- function(req, which = c("all", "datasets", "forms", "groups")) {
  verbose <- isTRUE(getOption("scto.verbose", default = TRUE))
  which <- match.arg(which)
  assert_class(req, c("httr2_request", "scto_request"))
  if (verbose) cli_progress_step("Reading metadata from the server...")
  metadata <- req |>
    req_url_path("console/forms-groups-datasets/get") |>
    req_perform() |>
    resp_body_json(simplifyVector = TRUE, flatten = TRUE)

  if (which == "all") invisible(metadata)
  else invisible(metadata[[which]])
}

#' @export
#' @rdname cto_metadata
cto_form_ids <- function(req) {
  assert_class(req, c("httr2_request", "scto_request"))
  req |>
    req_url_path("api/v2/forms/ids") |>
    req_perform() |>
    resp_body_json(simplifyVector = TRUE)
}
