# Download SurveyCTO Server Datasets

Downloads one or more datasets from a SurveyCTO server to a local
directory as CSV files.

## Usage

``` r
cto_dataset_download(id = NULL, dir = getwd(), overwrite = FALSE)
```

## Arguments

- id:

  A character vector of dataset IDs to download. If `NULL` (the
  default), the function queries the server for a list of all available
  datasets and downloads them all.

- dir:

  A string specifying the directory where CSV files will be saved.
  Defaults to the current working directory.

- overwrite:

  Logical. If `TRUE`, existing files in `dir` will be overwritten. If
  `FALSE` (the default), existing files are skipped to conserve
  bandwidth.

## Value

(Invisibly) A character vector of file paths to the successfully
downloaded CSVs. Returns `NULL` if no datasets were found.

## Details

- **Smart Downloading:** If `overwrite = FALSE`, the function checks if
  the target file already exists in `dir` and skips the download.

- **Error Handling:** If a specific dataset fails to download, a warning
  is printed with the dataset name, but the function continues
  processing the remaining list.

## See also

Other Dataset Management Functions:
[`cto_dataset_create()`](https://guturago.github.io/ctoclient/reference/cto_dataset_create.md),
[`cto_dataset_delete()`](https://guturago.github.io/ctoclient/reference/cto_dataset_delete.md),
[`cto_dataset_info()`](https://guturago.github.io/ctoclient/reference/cto_dataset_info.md),
[`cto_dataset_list()`](https://guturago.github.io/ctoclient/reference/cto_dataset_list.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# --- Example 1: Download a specific dataset ---
paths <- cto_dataset_download(id = "household_data", dir = tempdir())
df <- read.csv(paths[1])

# --- Example 2: Download all datasets, skip existing files ---
paths <- cto_dataset_download(dir = "my_data_folder", overwrite = FALSE)
} # }
```
