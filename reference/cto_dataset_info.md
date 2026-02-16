# Get Dataset Properties

Retrieves detailed metadata for a specific dataset, including its
configuration, schema, and status.

## Usage

``` r
cto_dataset_info(id)
```

## Arguments

- id:

  String. The unique identifier of the dataset.

## Value

A list containing the dataset properties.

## See also

Other Dataset Management Functions:
[`cto_dataset_create()`](https://guturago.github.io/ctoclient/reference/cto_dataset_create.md),
[`cto_dataset_delete()`](https://guturago.github.io/ctoclient/reference/cto_dataset_delete.md),
[`cto_dataset_download()`](https://guturago.github.io/ctoclient/reference/cto_dataset_download.md),
[`cto_dataset_list()`](https://guturago.github.io/ctoclient/reference/cto_dataset_list.md)

## Examples

``` r
if (FALSE) { # \dontrun{
ds_info <- cto_dataset_info(id = "hh_data")
} # }
```
