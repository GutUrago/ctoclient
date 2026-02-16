# Create or Upload to Server Datasets

These functions manage the lifecycle of SurveyCTO server datasets:
creating the container definition and populating it with data.

- `cto_dataset_create()`: Creates a new dataset with the specified
  configuration.

- `cto_dataset_upload()`: Uploads records from a CSV file to the
  specified dataset. Supports:

  - APPEND: add new records

  - MERGE: update existing records based on unique field

  - CLEAR: replace all data

## Usage

``` r
cto_dataset_create(
  id,
  title = id,
  discriminator = NULL,
  unique_record_field = NULL,
  allow_offline_updates = NULL,
  id_format_options = list(prefix = NULL, allowCapitalLetters = NULL, suffix = NULL,
    numberOfDigits = NULL),
  cases_management_options = list(otherUserCode = NULL, showFinalizedSentWhenTree = NULL,
    enumeratorDatasetId = NULL, showColumnsWhenTable = NULL, displayMode = NULL,
    entryMode = NULL),
  location_context = list(parentGroupId = 1, siblingBelow = list(itemClass = NULL, id =
    NULL), siblingAbove = list(itemClass = NULL, id = NULL))
)

cto_dataset_upload(
  id,
  file,
  upload_mode = c("APPEND", "MERGE", "CLEAR"),
  joining_field = NULL
)
```

## Arguments

- id:

  String. The unique identifier for the dataset (e.g.,
  "household_data").

- title:

  String. The display title of the dataset. Defaults to `id`.

- discriminator:

  String. The type of dataset to create.

- unique_record_field:

  String. The name of the field that uniquely identifies records.
  Required if `upload_mode` is "merge".

- allow_offline_updates:

  Logical. Whether the dataset allows updates while offline.

- id_format_options:

  List. Options for formatting IDs within the dataset.

- cases_management_options:

  List. Specific configurations for case management

- location_context:

  List. Metadata regarding where the dataset resides.

- file:

  String. Path to the local CSV file to upload.

- upload_mode:

  String. How the data should be handled.

- joining_field:

  String. The column name used to match records during a "merge". Often
  the same as `unique_record_field`.

## Value

A list containing the API response (metadata for creation, or job
summary for upload).

## See also

Other Dataset Management Functions:
[`cto_dataset_delete()`](https://guturago.github.io/ctoclient/reference/cto_dataset_delete.md),
[`cto_dataset_download()`](https://guturago.github.io/ctoclient/reference/cto_dataset_download.md),
[`cto_dataset_info()`](https://guturago.github.io/ctoclient/reference/cto_dataset_info.md),
[`cto_dataset_list()`](https://guturago.github.io/ctoclient/reference/cto_dataset_list.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# 1. Create the container
cto_dataset_create(
id = "hh_data",
title = "Household Data",
unique_record_field = "hh_id"
)

# 2. Upload data to it
cto_dataset_upload(
file = "data.csv",
id = "hh_data",
upload_mode = "merge",
joining_field = "hh_id"
)
} # }
```
