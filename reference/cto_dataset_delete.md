# Delete or Purge a Dataset

Functions to permanently remove data from the server.

- `cto_delete_dataset()`: **Permanently deletes** a dataset and all its
  associated data. This operation cannot be undone

- `cto_purge_dataset()`: Removes **all records** from the dataset but
  keeps the dataset definition (schema/ID) intact.

## Usage

``` r
cto_dataset_delete(id)

cto_dataset_purge(id)
```

## Arguments

- id:

  String. The unique identifier of the dataset.

## Value

A list confirming the operation status.

## See also

Other Dataset Management Functions:
[`cto_dataset_create()`](https://guturago.github.io/ctoclient/reference/cto_dataset_create.md),
[`cto_dataset_download()`](https://guturago.github.io/ctoclient/reference/cto_dataset_download.md),
[`cto_dataset_info()`](https://guturago.github.io/ctoclient/reference/cto_dataset_info.md),
[`cto_dataset_list()`](https://guturago.github.io/ctoclient/reference/cto_dataset_list.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# 1. Delete dataset
cto_dataset_delete(id = "hh_data")

# 2. Purge dataset
cto_dataset_purge(id = "hh_data")
} # }
```
