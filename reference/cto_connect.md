# Connect to and manage a SurveyCTO Server connection

- `cto_connect()` authenticates against a SurveyCTO server, verifies
  credentials, and handles cookies.

- `cto_set_connection()` manually sets or restores an existing session
  object.

- `cto_is_connected()` checks if an active session currently exists in
  the internal environment.

## Usage

``` r
cto_connect(server, username, password = NULL, cookies = TRUE)

cto_set_connection(session)

cto_is_connected()
```

## Arguments

- server:

  String. The subdomain of your SurveyCTO server. For example, if the
  full URL is `https://my-org.surveycto.com`, set this to `"my-org"`.

- username:

  String. The username or email address associated with the account.

- password:

  String. The user password. If left `NULL` (recommended), it prompts
  you for the password interactively.

- cookies:

  Logical. If `TRUE` (default), the client preserves cookies across
  requests and handles CSRF tokens automatically. This is required for
  maintaining stateful sessions to access endpoints that not available
  through the REST API.

- session:

  A `cto_session` object previously created by `cto_connect()`.

## Value

- `cto_connect()`: The session object (invisibly).

- `cto_set_connection()`: `NULL` (invisibly), called for its side effect
  of setting the session.

- `cto_is_connected()`: A logical `TRUE` or `FALSE`.

## Details

### Session Management

By default, this package operates **statefully** by preserving cookies
if the connection is established with the `cookies = TRUE` argument.
Upon successful authentication, the request object (`.session`) is
assigned to an internal package environment (`.ctoclient_env`).
Therefore, you do not need to pass a request object to other functions
in this package; they will automatically use the active session. If you
are working with multiple servers, please use `cto_set_connection()` to
switch the server connection.

### Security Best Practices

It is highly recommended to avoid hard-coding passwords in your scripts.

- **Interactive Session:** Pass the password securely via console input
  (leave it `NULL`) or keychain management tools.

- **Automation/Scripts:** Store your credentials in your `.Renviron`
  file (e.g., `SCTO_PASSWORD`) and retrieve them with
  [`Sys.getenv()`](https://rdrr.io/r/base/Sys.getenv.html).

## See also

[`httr2::req_auth_basic()`](https://httr2.r-lib.org/reference/req_auth_basic.html),
`usethis::edit_r_environ()`

## Examples

``` r
if (FALSE) { # \dontrun{
# 1. Standard authentication
cto_connect("my-org", "user@org.com", Sys.getenv("SCTO_PASSWORD"))

# 2. Check if connected
cto_is_connected()

# 3. Recommended for interactive use
con <- cto_connect("my-org", "user@org.com")

# 4. Restore and existing connection
cto_set_connection(con)
} # }
```
