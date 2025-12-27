

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
#' it's recommended to always use the environmental variables.
#'
#' @details
#' The function uses the \code{scto.verbose} option to control console
#' feedback. By default, it informs the user when authentication starts
#' and succeeds. You can silence this by setting \code{options(scto.verbose = FALSE)}.
#'
#' @return A \code{httr2_request} object prepared with the base URL and
#' authentication headers.
#'
#' @section Security & Credential Management:
#' For maximum security and workflow flexibility, it is highly recommended to
#' store your credentials as environment variables in your \code{.Renviron} file.
#' This allows you to call the function by passing the environment variables
#' directly to the arguments—see examples below. If using interactively, it's
#' recommended to leave `password = NULL` and input it when the system prompts.
#'
#' The object returned by this function is a standard \code{httr2} request.
#' \code{httr2} is designed to comply with high-level secret management
#' standards; specifically, it utilizes obfuscated storage for credentials in
#' memory and ensures that secrets like your password are not leaked into R
#' console logs or tracebacks.
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
#' req <- cto_request(Sys.getenv("SERVER"), Sys.getenv("USER"), Sys.getenv("PASS"))
#' }
cto_request <- function(server, username, password = NULL) {

  verbose <- isTRUE(getOption("scto.verbose", default = TRUE))
  assert_string(server, min.chars = 1)
  assert_string(username, min.chars = 1)
  if (!is.null(password)) assert_string(password, min.chars = 1)

  if (verbose) cli_progress_step("Requesting access to {.field {server}}")

  base_url <- str_glue("https://{server}.surveycto.com")
  req <- httr2::request(base_url) |>
    httr2::req_error(is_error = \(resp) FALSE) |>
    httr2::req_auth_basic(username, password) |>
    httr2::req_retry(max_tries = 3)

  if (verbose) cli_progress_step("Verifying credentials...")
  resp <- req_perform(req)
  cto_req_status(resp, server)

  class(req) <- c(class(req), "scto_request")
  if (verbose) cli_progress_step("Access granted!")

  invisible(req)
}


# Customized errors ----

cto_req_status <- function(resp, server) {
  status <- httr2::resp_status(resp)
  if (status == 200) return(invisible(TRUE))
  cli_abort(
    c(
      "x" = "SurveyCTO API request to {.field {server}} failed [Status {.val {status}}].",

      # 400: URL Error
      if (status == 400) {
        c("!" = "The request to {.val {server}} was malformed.",
          "*" = "Check that your URL parameters (like {.field date}) are correctly formatted.")
      }
      # 401: Authentication
      else if (status == 401) {
        c("!" = "Authentication to {.val {server}} failed.",
          "*" = "Confirm your username is registered on the server.",
          "*" = "Verify that your password is correct for this specific server.")
      }
      # 403: Access Denied
      else if (status == 403) {
        c("!" = "Permission denied on {.val {server}}.",
          "*" = "Your user role must have {.strong 'Can download data'} permissions.",
          "*" = "On multi-team servers, ensure your role has access to the form's group.")
      }
      # 404: Not Found
      else if (status == 404) {
        c("!" = "Resource not found on {.val {server}}.",
          "i" = "Check for typos in the {.field form_id} and ensure the server address is correct.")
      }
      # 409: Parallel requests
      else if (status == 409) {
        c("!" = "Parallel request conflict on {.val {server}}.",
          "i" = "SurveyCTO API does not support concurrent requests.",
          "v" = "Please wait for your other API calls to finish and try again.")
      }
      # 412: API access disabled
      else if (status == 412) {
        c("!" = "API access is disabled for this user on {.val {server}}.",
          "*" = "Go to the server console and enable 'Allow API access' for this user role.")
      }
      # 417: Rate Limit
      else if (status == 417) {
        c("!" = "Rate limit reached for {.val {server}}.",
          "i" = "Full data pulls (date=0) are restricted to once every 300 seconds.",
          "v" = "Wait a few minutes before requesting all submissions again.")
      }
    )
  )
}



