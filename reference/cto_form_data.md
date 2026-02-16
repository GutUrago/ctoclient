# Download and Tidy SurveyCTO Form Data

Downloads submission data from a SurveyCTO server in wide JSON format.
Encrypted forms are supported via a private key. When `tidy = TRUE`
(default), the function uses the form's XLSForm definition to convert
variables to appropriate R types, drop structural fields, and organize
columns for analysis.

## Usage

``` r
cto_form_data(
  form_id,
  private_key = NULL,
  start_date = as.POSIXct("2000-01-01"),
  status = c("approved", "rejected", "pending"),
  tidy = TRUE
)
```

## Arguments

- form_id:

  A string specifying the SurveyCTO form ID.

- private_key:

  An optional path to a `.pem` private key file. Required if the form is
  encrypted.

- start_date:

  A POSIXct timestamp. Only submissions received after this date/time
  are requested. Defaults to `"2000-01-01"`.

- status:

  A character vector of submission statuses to include. Must be a subset
  of `"approved"`, `"rejected"`, and `"pending"`. Defaults to all three.

- tidy:

  Logical; if `TRUE`, attempts to clean and restructure the raw
  SurveyCTO output using the XLSForm definition.

## Value

A `data.frame` containing the downloaded submissions.

If `tidy = FALSE`, the raw parsed JSON response is returned. If
`tidy = TRUE`, a cleaned version with standardized column types and
ordering is returned.

Returns an empty `data.frame` when no submissions are available.

## Details

When `tidy = TRUE`, the function performs several common post-processing
steps:

- **Type conversion:** Converts numeric, date, and datetime fields to
  native R types based on question types in the XLSForm.

- **Structural cleanup:** Removes layout-only fields such as notes,
  group markers, and repeat delimiters.

- **Column ordering:** Places key submission metadata (for example,
  completion and submission dates) first, followed by survey variables
  in form order.

- **Media fields:** Strips URLs from image, audio, and video fields,
  leaving only the filename.

- **Geopoints:** Splits geopoint variables into four columns with
  `_latitude`, `_longitude`, `_altitude`, and `_accuracy` suffixes when
  not already present.

## See also

Other Form Management Functions:
[`cto_form_attachment()`](https://guturago.github.io/ctoclient/reference/cto_form_attachment.md),
[`cto_form_data_attachment()`](https://guturago.github.io/ctoclient/reference/cto_form_data_attachment.md),
[`cto_form_dofile()`](https://guturago.github.io/ctoclient/reference/cto_form_dofile.md),
[`cto_form_languages()`](https://guturago.github.io/ctoclient/reference/cto_form_languages.md),
[`cto_form_metadata()`](https://guturago.github.io/ctoclient/reference/cto_form_metadata.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# Download raw submissions
raw <- cto_form_data("my_form_id", tidy = FALSE)

# Download and tidy encrypted data
clean <- cto_form_data("my_form_id", private_key = "keys/my_key.pem")
} # }
```
