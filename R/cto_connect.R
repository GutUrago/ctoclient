

#' Connect to and manage a SurveyCTO Server connection
#'
#' @description
#' * `cto_connect()` authenticates against a SurveyCTO server, verifies credentials,
#' and handles cookies.
#'
#' * `cto_set_connection()` manually sets or restores an existing session object.
#'
#' * `cto_is_connected()` checks if an active session currently exists in the
#' internal environment.
#'
#' @details
#' ## Session Management
#' Unlike typical `httr2` workflows, this package operates **statefully**.
#' Upon successful authentication, the request object is assigned to an internal
#' package environment (`.ctoclient_env`). You do not need to pass a request
#' object to other functions in this package; they will automatically use the
#' active session.
#'
#' ## Security Best Practices
#' It is highly recommended to avoid hard-coding passwords in your scripts.
#'
#' * **Interactive Session:** Pass the password securely via console input (leave it `NULL`) or
#'   keychain management tools.
#' * **Automation/Scripts:** Store your credentials in your `.Renviron` file
#'   (e.g., `SCTO_PASSWORD`) and retrieve them with [Sys.getenv()].
#'
#' @param server String. The subdomain of your SurveyCTO server.
#'   For example, if the full URL is `https://my-org.surveycto.com`,
#'   set this to `"my-org"`.
#' @param username String. The username or email address associated with the account.
#' @param password String. The user password. If left `NULL` (recommended),
#' it prompts you for the password interactively.
#' @param session A `cto_session` object previously created by `cto_connect()`.
#'
#' @return
#' * `cto_connect()`: The session object (invisibly).
#' * `cto_set_connection()`: `NULL` (invisibly), called for its side effect of setting the session.
#' * `cto_is_connected()`: A logical `TRUE` or `FALSE`.
#'
#' @seealso [httr2::req_auth_basic()], [usethis::edit_r_environ()]
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # 1. Standard authentication
#' cto_connect("my-org", "user@org.com", Sys.getenv("SCTO_PASSWORD"))
#'
#' # 2. Check if connected
#' cto_is_connected()
#'
#' # 3. Recommended for interactive use
#' con <- cto_connect("my-org", "user@org.com")
#'
#' # 4. Restore and existing connection
#' cto_set_connection(con)
#' }
cto_connect <- function(server, username, password = NULL) {

  verbose <- get_verbose()

  checkmate::assert_string(server)
  checkmate::assert_string(username)
  checkmate::assert_string(password, null.ok = TRUE)

  if (verbose) cli_progress_step(
    "Requesting access to {.field {server}}...",
    "Access to {.field {server}} granted successfully",
    "Failed to access {.field {server}}"
    )

  base_url <- str_glue("https://{server}.surveycto.com")

  req <- httr2::request(base_url)
  req <- httr2::req_user_agent(req, "ctoclient package in R")
  req <- httr2::req_auth_basic(req, username, password)
  req <- httr2::req_throttle(req, capacity = 30, fill_time_s = 60)
  req <- httr2::req_cookie_preserve(req, tempfile())
  req <- httr2::req_error(
    req,
    body = function(resp) {

      body <- tryCatch(
        httr2::resp_body_json(resp),
        error = function(e) NULL
      )

      if (!is.null(body) && !is.null(body$error$message)) {
        return(body$error$message)
      }

      return(NULL)
    }
    )

  resp <- httr2::req_perform(req)
  csrf_exist <- httr2::resp_header_exists(resp, "x-csrf-token")
  if (csrf_exist) {
    csrf <- httr2::resp_header(resp, "x-csrf-token")
    req <- httr2::req_headers(req, `x-csrf-token` = csrf)
  }

  req$server <- server
  class(req) <- c(class(req), "cto_session")
  assign(".session", req, envir = .ctoclient_env)
  invisible(req)
}


#' @export
#' @rdname cto_connect
cto_set_connection <- function(session) {
  if (!inherits(session, "cto_session")) {
    cli_abort(c(
      x = "The provided {.var session} is not valid SurveyCTO session.",
      i = "Please connect first using {.run ctoclient::cto_connect()}."
    ))
  }
  assign(".session", session, envir = .ctoclient_env)
}

#' @export
#' @rdname cto_connect
cto_is_connected <- function() exists(".session", envir = .ctoclient_env)



