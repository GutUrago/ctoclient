

#' Create an Authenticated SurveyCTO Request Object
#'
#' @description
#' Initializes a `httr2` request object with the necessary server URL and
#' Basic Authentication credentials.
#'
#'
#' @param server String. The name of your SurveyCTO server (the subdomain).
#' For example, if your URL is \code{https://example.surveycto.com},
#' use \code{"example"}.
#' @param username String. The username/email for a user account.
#' @param password String. The password for the specified user. You should avoid
#' entering the password directly when calling this function, as it will be
#' captured by `.Rhistory`. Instead, leave it unset (`NULL`) and the default behavior
#' will prompt you for it interactively. If needed for automation purposes,
#' it's recommended to always use the environment variables.
#'
#' @details
#' The function uses the \code{scto.verbose} option to control console
#' feedback. By default, it informs the user when authentication starts
#' and succeeds. You can silence this by setting \code{options(scto.verbose = FALSE)}.
#'
#' @return An authenticated \code{httr2_request} object. The endpoint can be
#' modified using \code{\link[httr2]{req_url_path}()}, \code{\link[httr2]{req_url_query}()},
#' and others.
#'
#' @section Security & Credential Management:
#' For maximum security and workflow flexibility, it is highly recommended to
#' store your credentials as environment variables in your \code{.Renviron} file.
#' This allows you to call the function by passing the environment variables
#' directly to the arguments—see examples below. If using interactively, it's
#' recommended to leave `password = NULL` and input it when the system prompts.
#'
#' The object returned by this function is a standard \code{httr2} request, which is designed
#' to comply with high-level secret management standards.
#'
#' @export
#'
#'
#' @seealso \code{\link[httr2]{req_auth_basic}()}, \code{\link[usethis]{edit_r_environ}()}, \code{\link{Sys.setenv}()}
#'
#'
#' @examples
#' \dontrun{
#' # Direct authentication
#' req <- cto_request("my-org", "user@org.com", "pw")
#'
#' # Input password when prompted
#' req <- cto_request("my-org", "user@org.com")
#'
#' # Using environment variables for enhanced security (Recommended)
#' req <- cto_request("my-org", Sys.getenv("USER"), Sys.getenv("PASS"))
#' }
cto_request <- function(server, username, password = NULL) {

  verbose <- isTRUE(getOption("scto.verbose", default = TRUE))

  assert_string(server, min.chars = 1)
  assert_string(username, min.chars = 1)
  if (!is.null(password)) assert_string(password, min.chars = 1)

  if (verbose) cli_progress_step("Requesting access to {.field {server}}")

  cookie_jar <- tempfile()

  base_url <- str_glue("https://{server}.surveycto.com")
  req <- httr2::request(base_url) |>
    httr2::req_user_agent("scto package in R") |>
    httr2::req_auth_basic(username, password) |>
    httr2::req_retry(max_tries = 3) |>
    httr2::req_cookie_preserve(cookie_jar)

  if (verbose) cli_progress_step("Verifying credentials...")
  resp <- req_perform(req)

  if (httr2::resp_header_exists(resp, "x-csrf-token")) {
    req <- httr2::req_headers(
      req,
      `x-csrf-token` = httr2::resp_header(resp, "x-csrf-token")
    )
  }

  class(req) <- c(class(req), "scto_request")
  if (verbose) cli_progress_step("Access granted!")
  return(req)
}

