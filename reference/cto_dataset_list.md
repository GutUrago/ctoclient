# List Available Server Datasets

Retrieves a list of datasets that the authenticated user has access to.
Results can be filtered by team and ordered by specified fields.

## Usage

``` r
cto_dataset_list(
  order_by = "createdOn",
  sort = c("ASC", "DESC"),
  team_id = NULL
)
```

## Arguments

- order_by:

  String. The field to sort the results by. Options are: `"id"`,
  `"title"`, `"createdOn"`, `"modifiedOn"`, `"status"`, `"version"`, or
  `"discriminator"`. Defaults to `"createdOn"`.

- sort:

  String. The direction of the sort: `"asc"` (ascending) or `"desc"`
  (descending). Defaults to `"asc"`.

- team_id:

  String (Optional). Filter datasets by a specific Team ID. If provided,
  only datasets accessible to that team are returned. Example:
  `'team-456'`.

## Value

A data frame containing the metadata of available datasets.

## See also

Other Dataset Management Functions:
[`cto_dataset_create()`](https://guturago.github.io/ctoclient/reference/cto_dataset_create.md),
[`cto_dataset_delete()`](https://guturago.github.io/ctoclient/reference/cto_dataset_delete.md),
[`cto_dataset_download()`](https://guturago.github.io/ctoclient/reference/cto_dataset_download.md),
[`cto_dataset_info()`](https://guturago.github.io/ctoclient/reference/cto_dataset_info.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# List all datasets sorted by creation date
ds_list <- cto_dataset_list()

# List datasets for a specific team, ordered by title
team_ds <- cto_dataset_list(team_id = "team-123", order_by = "title")
} # }
```
