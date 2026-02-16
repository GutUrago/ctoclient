# Retrieve Server Metadata and Resource Lists

These functions retrieve various metadata and lists of resources (forms,
groups, teams, roles, users) from the SurveyCTO server.

- `cto_metadata()`: Retrieves a combined structure of forms, groups, and
  datasets (legacy console endpoint).

- `cto_form_ids()`: Returns a simple vector of all form IDs.

- `cto_group_list()`: Lists all form groups.

- `cto_team_list()`: Lists all available team IDs.

- `cto_role_list()`: Lists all defined user roles.

- `cto_user_list()`: Lists all users on the server.

## Usage

``` r
cto_form_ids()

cto_metadata(which = c("all", "datasets", "forms", "groups"))

cto_group_list(
  order_by = c("createdOn", "id", "title"),
  sort = c("ASC", "DESC"),
  parent_group_id = NULL
)

cto_team_list()

cto_role_list(
  order_by = c("createdOn", "id", "title", "createdBy"),
  sort = c("ASC", "DESC")
)

cto_user_list(
  order_by = c("createdOn", "username", "roleId", "modifiedOn"),
  sort = c("ASC", "DESC"),
  role_id = NULL
)
```

## Arguments

- which:

  String. Specifies which subset of metadata to return for
  `cto_metadata()`. One of:

  - `"all"` (default): Returns a list containing groups, datasets, and
    forms.

  - `"groups"`: Returns a data frame of form groups.

  - `"datasets"`: Returns a data frame of server datasets.

  - `"forms"`: Returns a data frame of deployed forms.

- order_by:

  String. Field to sort the results by. Available fields vary by
  function (e.g., `"createdOn"`, `"id"`, `"title"`, or `"username"`).

- sort:

  String. Sort direction: `"ASC"` (ascending) or `"DESC"` (descending).

- parent_group_id:

  Number (Optional). Filter groups by their parent group ID.

- role_id:

  String (Optional). Filter users by a specific Role ID.

## Value

The return value depends on the function:

- `cto_form_ids()` and `cto_team_list()` return a **character vector**
  of IDs.

- `cto_metadata()` returns a **list** (if `which = "all"`) or a **data
  frame**.

- `cto_group_list()`, `cto_role_list()`, and `cto_user_list()` return a
  **list** or **data frame** of the requested resources (depending on
  pagination handling).

## Examples

``` r
if (FALSE) { # \dontrun{
# --- 1. Basic Metadata ---
# Get all form IDs as a vector
ids <- cto_form_ids()

# Get detailed metadata about forms
meta_forms <- cto_metadata("forms")

# --- 2. Resource Lists ---
# List all groups, sorted by title
groups <- cto_group_list(order_by = "title", sort = "asc")

# List all users with a specific role
admins <- cto_user_list(role_id = "admin_role_id")
} # }
```
